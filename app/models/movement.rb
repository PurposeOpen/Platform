# == Schema Information
#
# Table name: movements
#
#  id                        :integer          not null, primary key
#  name                      :string(20)       not null
#  url                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  subscription_feed_enabled :boolean
#  created_by                :string(255)
#  updated_by                :string(255)
#  password_digest           :string(255)
#  slug                      :string(255)
#  crowdring_url             :string(255)
#

class Movement < ActiveRecord::Base
  extend FriendlyId
  acts_as_user_stampable

  has_one  :member_count_calculator, :dependent => :destroy
  has_one  :homepage, :dependent => :destroy, :conditions => {:draft => false}
  has_one  :image_settings, :dependent => :destroy
  has_many :draft_homepages, :class_name => 'Homepage', :conditions => {:draft => true}
  has_many :campaigns, :dependent => :destroy
  has_many :join_emails, :through => :movement_locales
  has_many :email_footers, :through => :movement_locales

  has_many :movement_locales, :dependent => :destroy
  has_many :languages, :through => :movement_locales

  has_many :content_page_collections, :dependent => :destroy

  has_many :user_affiliations, :dependent => :destroy
  has_many :platform_users, :through => :user_affiliations, :dependent => :destroy
  has_many :members, :class_name => User, :dependent => :destroy

  has_many :downloadable_assets, :dependent => :destroy
  has_many :images, :dependent => :destroy

  has_many :pages, :dependent => :destroy

  has_many :action_pages, :dependent => :destroy
  has_many :content_pages, :dependent => :destroy

  accepts_nested_attributes_for :languages, :image_settings

  friendly_id :name, :use => :slugged
  has_secure_password
  before_validation :assign_default_password

  after_initialize :ensure_homepage_exists
  after_create { MemberCountCalculator.init(self) }

  validates_presence_of :homepage
  validates_length_of :name, :maximum => 20, :minimum => 3
  validates_format_of :url, :with => %r[\b(([\w-]+://)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))], :message => "must be valid"
  validates_each :url do |record, attr, value|
    urls = (value || "").split("\n")
    valid = true
    urls.each do |url|
      valid = false unless url =~ %r[\b(([\w-]+://)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))]
    end
    unless valid
      record.errors.add attr, "must be a list of valid URLs"
    end
  end

  scope :for_all_roles, lambda { for_role(UserAffiliation::ROLES) }
  scope :for_role, lambda { |role| where(:user_affiliations => {:role => role}) }

  default_scope :include => :homepage

  def iso_codes=(iso_codes)
    codes = Array.wrap(iso_codes)
    Language.by_code(*codes).each do |l|
      self.movement_locales.build :language => l
    end
  end

  def iso_codes
    self.movement_locales.map(&:iso_code)
  end

  def default_iso_code
    self.default_language.try :iso_code
  end

  def default_iso_code=(iso_code)
    self.movement_locales.by_code(iso_code).includes(:language).first.update_attributes :default => true
  end

  # TODO This gets fixed when we kill or upgrade friendly_id and/or merge action pages with content pages.
  def find_page(query)
    self.pages.find(query)
  end

  def find_page_unscoped(query)
    Page.unscoped.for_preview(self.id).find(query)
  end

  def find_published_page(query)
    self.action_pages.published.find(query)
  end

  def footer_for_language(iso_code)
    email_footers.find {|email_footer| email_footer.language.iso_code == iso_code}
  end

  def join_page
    self.pages.find("join")
  end

  def default_locale
    movement_locales.default.first
  end

  def default_language
    languages.default.first
  end

  def default_language=(language)
    language_id = language.kind_of?(ActiveRecord::Base) ? language.id : language
    lang = languages.find_by_id(language_id) || languages.to_a.find {|l| l.id == language_id}

    raise RuntimeError.new("Language doesn't belong to movement") if lang.blank?

    demote_default_language_if_set
    promote_language_to_default(lang)
  end

  def unsubscribed_members
    members.unsubscribed
  end

  def non_default_languages
    movement_locales.non_default.includes(:language).map(&:language)
  end

  def existing_sources(prettify = false)
    store_key = "/existing_sources/#{self.id}"
    Rails.cache.fetch(store_key){User.select('DISTINCT source').where(:movement_id => self.id).map {|row| [row.source.send(prettify ? :titleize : :to_sym), row.source] if row.source.present? }}
  end

  def pushes
    campaigns.map(&:pushes).flatten
  end

  def image_settings_for(setting_module)
    return {} unless image_settings
    [:image_height, :image_width, :image_dpi].inject({}){|r, k| r.merge(k => image_settings["#{setting_module}_#{k}"])}
  end

  private

  def default_candidate(language_id)
    languages.find(language_id)
  end

  def demote_default_language_if_set
    self.movement_locales.default.update_all(:default => false)
  end

  def promote_language_to_default(lang)
    if self.new_record?
      self.movement_locales.create(:language_id => lang.id, :default => true)
    else
      self.movement_locales.where(:language_id => lang.id).update_all(:default => true)
    end
  end

  def ensure_homepage_exists
    self.homepage ||= Homepage.new(:movement => self)
  end

  def default_password
    self.slug || normalize_friendly_id(self.name.try(:parameterize))
  end

  def assign_default_password
    if self.password_digest.blank?
      self.password = default_password
      self.password_confirmation = default_password
    end
  end

end
