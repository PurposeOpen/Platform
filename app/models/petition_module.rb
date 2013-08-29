# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

# "Petition Ask" module -- requests that user signs a petition
class PetitionModule < ContentModule

  has_many :petition_signatures, :foreign_key => :content_module_id
  option_fields :signatures_goal, :thermometer_threshold, :button_text, :petition_statement, :custom_fields,
      :comment_label, :comment_text, :comments_enabled

  option_fields :active, :disabled_title, :disabled_content

  def signatures_goal=(value)
    write_option_field_value :signatures_goal, value.to_i
  end

  def thermometer_threshold=(value)
    write_option_field_value :thermometer_threshold, value.to_i
  end

  after_initialize :defaults

  warnings do
    # The following two validations aren't being inherited properly.
    validates_length_of :title, :maximum => 128, :minimum => 3, :if => :is_ask?
    validates_length_of :public_activity_stream_template, :maximum => 1024, :minimum => 3, :if => :is_ask?

    validates_presence_of :signatures_goal
    validates_numericality_of :signatures_goal, :greater_than_or_equal_to => 0, :if => :signatures_goal
    validates_presence_of :thermometer_threshold
    validates_numericality_of :thermometer_threshold, :greater_than_or_equal_to => 0, :less_than_or_equal_to => :signatures_goal, :if => :signatures_goal
    validates_length_of :button_text, :maximum => 64
    validates_length_of :petition_statement, :minimum => 1
    validates_presence_of :comment_label, :if => :comments_enabled?
    validates_presence_of :disabled_title, :unless => :active?
    validates_presence_of :disabled_content, :unless => :active?
  end

  placeable_in SIDEBAR

  def take_action(user, action_info, page)
    return if PetitionSignature.where(:content_module_id => self.id, :user_id => user.id).count > 0
    petition_signature = PetitionSignature.new(petition_signature_attributes_hash)
    petition_signature.user = user
    petition_signature.action_page = page
    petition_signature.email = action_info[:email] if action_info.present?
    petition_signature.comment = action_info[:comment] if action_info.present?
    petition_signature.save
    petition_signature
  end

  def signatures
    page = pages.first
    return 0 unless page
    crowdring_url = page.movement.crowdring_url
    PetitionSignature.where(:page_id => page.id).count +
      (crowdring_url.present? && page.crowdring_campaign_name.present? ? crowdring_member_count(crowdring_url, page.crowdring_campaign_name).to_i : 0 )
  end

  def crowdring_member_count(crowdring_url, crowdring_campaign_name)
    get_count_uri = crowdring_campaign_endpoint(crowdring_url, crowdring_campaign_name)
    Rails.cache.fetch(get_count_uri, :expires_in => 30.minutes) do
      fetch_count_from_crowdring(get_count_uri)
    end
  end

  def can_remove_from_page?
    false
  end

  def as_json(opts={})
    super(opts).merge :signatures => signatures
  end

  def comments_enabled?
    ["1", true].include? comments_enabled
  end

  def active?
    active == 'true'
  end

  private

  def crowdring_campaign_endpoint(crowdring_url, crowdring_campaign_name)
    encoded_uri = URI::encode("#{crowdring_url}/campaign/#{crowdring_campaign_name}/campaign-member-count")
    URI.parse(encoded_uri)
  end

  def fetch_count_from_crowdring(get_count_uri)
    ActiveSupport::JSON.decode(open(get_count_uri))["count"]
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace
    0
  end

  def petition_signature_attributes_hash
    array = []
    array = self.custom_fields.map{|cf| [cf[:name].to_sym , nil] } unless self.custom_fields.blank?
    array.push([:content_module_id, self.id])
    array = Hash[*array.flatten(1)]
  end

  def defaults
    self.button_text = "Sign" unless self.button_text
    self.public_activity_stream_template = "{NAME|A member}, {COUNTRY|}<br/>[{HEADER}]" unless self.public_activity_stream_template
    self.comments_enabled = true if self.comments_enabled.nil?
    self.active = 'true' unless self.active
  end

end
