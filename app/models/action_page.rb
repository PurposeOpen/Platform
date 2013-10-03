# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  action_sequence_id         :integer
#  name                       :string(64)
#  created_at                 :datetime
#  updated_at                 :datetime
#  deleted_at                 :datetime
#  position                   :integer
#  required_user_details      :text
#  views                      :integer          default(0), not null
#  created_by                 :string(255)
#  updated_by                 :string(255)
#  alternate_key              :integer
#  paginate_main_content      :boolean          default(FALSE)
#  no_wrapper                 :boolean
#  type                       :string(255)
#  content_page_collection_id :integer
#  movement_id                :integer
#  slug                       :string(255)
#  live_page_id               :integer
#  crowdring_campaign_name    :string(255)
#

class ActionPage < Page
  include CacheableModel
  include QuickGoable
  include Errors

  acts_as_paranoid
  belongs_to :action_sequence
  has_many :autofire_emails


  has_many :drafts, :class_name => "ActionPage", :foreign_key => "live_page_id"
  belongs_to :live_action_page, :class_name => "ActionPage", :foreign_key => "live_page_id"

  acts_as_list :scope => :action_sequence
  serialize :required_user_details, JSON

  validates_presence_of :action_sequence
  validates_uniqueness_of :position, :scope => [:action_sequence_id, :live_page_id, :deleted_at], :if => Proc.new { |page| page.live_action_page.nil? }

  scope :published, ->{where(:action_sequences => { :published => true }).joins(:action_sequence)}

  delegate :campaign, :to => :action_sequence

  after_create :seed_initial_module
  after_save ->{campaign.touch if !live_page_id}
  after_save ->{Rails.cache.delete("/grouped_select_options_pages/#{movement_id}")}
  after_save ->{Rails.cache.delete("/select_options_pages/#{movement_id}")}

  attr_accessor :seeded_module
  attr_accessible :seeded_module, :name, :action_sequence, :position, :required_user_details, :no_wrappers, :movement_id, :crowdring_campaign_name

  DEFAULT_REQUIRED_USER_DETAILS = [
      {:field => "first_name", :default => "required", :label => "First Name"},
      {:field => "last_name", :default => "required", :label => "Last Name"},
      {:field => "country", :default => "required", :label => "Country"},
      {:field => "postcode", :default => "required", :label => "Postcode"},
      {:field => "mobile_number", :default => "hidden", :label => "Mobile"},
      {:field => "home_number", :default => "hidden", :label => "Home"},
      {:field => "suburb", :default => "hidden", :label => "Suburb"},
      {:field => "street_address", :default => "hidden", :label => "Street Address"}
  ]

  scope :with_content_modules, lambda { |content_module_types| includes(:content_modules).where("content_modules.type IN (?)", content_module_types) }
  scope :for_movement_id, lambda { |movement_id| where(movement_id: movement_id) }

  class << self
    def page_options(movement_id, possible_module_types)
      pages_for(movement_id, possible_module_types).collect { |action_page| [action_page.name, action_page.id] }
    end

    def page_ids_for_movement(movement_id, possible_module_types)
      pages_for(movement_id, possible_module_types).select("pages.id").collect(&:id).map(&:to_s)
    end

    private

    def pages_for(movement_id, possible_module_types)
      ActionPage.with_content_modules(possible_module_types).for_movement_id(movement_id)
    end
  end

  def required_user_details
    serialized = read_attribute(:required_user_details)
    write_attribute(:required_user_details, serialized = {}) if serialized.nil?
    serialized.merge(:email => :required) # TODO Add a migration to formalize this.
  end

  def non_hidden_user_details
    required_user_details.delete_if {|key, value| value.to_sym == :hidden } if required_user_details
  end

  def required_user_details=(new_details)
    symbolize = new_details.inject({}) { |memo, (k,v)| memo[k.to_sym] = v.to_sym; memo }
    write_attribute(:required_user_details, symbolize)
  end

  def next
    ActionPage.find_by_action_sequence_id_and_position(self.action_sequence, self.position + 1)
  end

  def static?
    self.action_sequence && self.action_sequence.static?
  end

  def has_an_ask?
    !ask_module.nil?
  end

  def ask_module
    ask_module_for_language(self.movement.default_language)
  end

  def ask_module_for_language(language)
    self.content_modules.where(:language_id => language).to_a.find { |cm| cm.is_ask? }
  end

  def is_donation?
    has_module_of_type? DonationModule
  end

  def is_tax_deductible_donation?
    has_module_of_type? TaxDeductibleDonationModule
  end

  def is_non_tax_deductible_donation?
    has_module_of_type? NonTaxDeductibleDonationModule
  end

  def is_tax_deductible_taf_donation?
    has_module_of_type? TaxDeductibleTafDonationModule
  end

  def is_non_tax_deductible_taf_donation?
    has_module_of_type? NonTaxDeductibleTafDonationModule
  end

  def is_join?
    has_module_of_type? JoinModule
  end

  def is_unsubscribe?
    has_module_of_type? UnsubscribeModule
  end

  def is_tell_a_friend?
    has_module_of_type? TellAFriendModule
  end

  def has_a_tell_a_friend?
    (is_non_tax_deductible_taf_donation? || is_tell_a_friend? || is_tax_deductible_taf_donation?)
  end

  def subscribes_user?
    self.has_an_ask? and ask_module.subscribes_user_on_action?
  end

  def has_counter?
    is_donation? or has_module_of_type? EmailTargetsModule or has_module_of_type? PetitionModule
  end

  def requires_user_details?
    self.content_modules.any? { |cm| cm.requires_user_details? }
  end

  def add_view!
    ActionPage.update_all("views = views + 1", "id = #{id}")
  end

  def cache_key
    action_sequence_seed = self.action_sequence.nil? ? "no_action_sequence" : friendly_id
    campaign_seed = (self.action_sequence.nil? || self.action_sequence.campaign.nil?) ? "static" : self.action_sequence.campaign.friendly_id
    seed = "#{self.friendly_id}/action_sequence/#{action_sequence_seed}/campaign/#{campaign_seed}"
    self.class.generate_cache_key(seed)
  end

  def process_action_taken_by(member, action_info = {})
    if has_an_ask?
      user_response = ask_module_for_language(member.language).take_action(member, action_info, self)
      deliver_autofire_email_to(member, user_response)
    end
  end

  def tafs_for_locale(language)
    content_modules.where(:type => 'TellAFriendModule', :language_id => language).all
  end

  def should_have_autofire_emails?
    self.has_an_ask? && !self.is_join? && !self.is_unsubscribe?
  end

  def autofire_email_for_language(language)
    autofire_emails.where(:language_id => language).first
  end

  def set_up_autofire_emails
    if should_have_autofire_emails?
      self.possible_languages.each do |language|
        autofire_emails.where(:action_page_id => self.id, :language_id => language.id).first_or_create(:action_page => self)
      end
    end
  end

  def link_existing_modules_to(target_page, container)
    find_modules_for_container(container).select { |cm| not target_page.content_modules.include? cm }.each do |cm|
      target_page.content_module_links.create!(:layout_container => container, :content_module => cm)
    end
  end

  def sibling_pages
    action_sequence.action_pages - [self]
  end

  def language_enabled?(language)
    if action_sequence.blank? then return false end
    if action_sequence.published == false then return Errors::NotFound end
    action_sequence.language_enabled? language
  end

  def as_json(opts={})
    language = language_option(opts)
    taf = action_sequence.first_taf(language)
    {
      facebook_title: taf.try {|taf| taf.options['facebook_title']},
      facebook_description: taf.try {|taf| taf.options['facebook_description']},
      facebook_image_url: taf.try {|taf| taf.options['facebook_image_url']},
      actions_taken_count: count_actions,
      shares: share_counts,
      footer_content_modules: modules_as_json(modules_for_container_and_language(ContentModule::FOOTER, language), opts)
    }.merge(self.required_user_details).merge(super)
  end

  def initialize_defaults!
    self.views = 0
    self.name = copy_attribute_with_next_version(:name)
  end

  def count_actions
    cache_key = "count_actions_for_page_#{self.id}"
    Rails.cache.fetch(cache_key, expires_in: 24.hours, raw: true) do
      UserActivityEvent.where(:activity => UserActivityEvent::Activity::ACTION_TAKEN, :page_id => self.id).count
    end
  end

  def update_page_action_taken_counter
    cache_key = "count_actions_for_page_#{self.id}"
    if Rails.cache.read(cache_key, raw: true)
      Rails.cache.increment(cache_key, 1)
    else
      count_actions
    end
  end
  
  private

  def share_counts
    Share.counts(self.id) if self.has_a_tell_a_friend?
  end

  
  def seed_initial_module
    return if self.seeded_module.blank?
    module_class = self.seeded_module.classify.constantize
    mod = module_class.new :language => self.movement.default_language
    mod.save(:validate => false)
    self.content_module_links.create :content_module => mod, :layout_container => ContentModule::SIDEBAR
  end

  def has_module_of_type?(module_type)
    self.content_modules.any? { |cm| cm.is_a?(module_type) }
  end

  def deliver_autofire_email_to(member, user_response)
    email = AutofireEmail.find_by_action_page_id_and_language_id(self.id, member.language.id)
    additional_tokens = user_response.respond_to?(:autofire_tokens) ? user_response.autofire_tokens : nil
    SendgridMailer.user_email(email, member, additional_tokens) if (email && email.enabled_and_valid?)
  end
  handle_asynchronously(:deliver_autofire_email_to) unless Rails.env == "test"

end
