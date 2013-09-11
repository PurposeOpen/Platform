# == Schema Information
#
# Table name: action_sequences
#
#  id                :integer          not null, primary key
#  campaign_id       :integer
#  name              :string(64)
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  created_by        :string(255)
#  updated_by        :string(255)
#  alternate_key     :integer
#  options           :text
#  published         :boolean
#  enabled_languages :text
#  slug              :string(255)
#

class ActionSequence < ActiveRecord::Base
  extend FriendlyId
  include CacheableModel
  include QuickGoable

  acts_as_paranoid
  has_many :action_pages, order: :position, dependent: :destroy
  belongs_to :campaign, touch: true
  delegate :movement, to: :campaign, allow_nil: true #TODO allow_nil should become false after data cleanup with foreign keys
  serialize :enabled_languages, JSON

  scope :static, where(campaign_id: nil)
  friendly_id :name, use: :slugged

  include SerializedOptions
  option_fields :email_body, :email_subject, :tweet_text, :facebook_image

  after_initialize :defaults

  validate :unique_name_within_campaign
  validates_length_of :name, maximum: 64, minimum: 3

  def static?
    self.campaign.nil?
  end

  def action_pages_with_counter
    action_pages.select &:has_counter?
  end

  def duplicate
    self.dup(include: {action_pages: [:autofire_emails, {content_module_links: :content_module}]}) do |original, copy|
      copy.initialize_defaults! if copy.respond_to?(:initialize_defaults!)
    end
  end

  def initialize_defaults!
    self.name = copy_attribute_with_next_version(:name)
    self.published = false
  end

  def self.get_from_cache(a_campaign,sequence_friendly_id)
    key = generate_cache_key(a_campaign, sequence_friendly_id)
    sequence = Rails.cache.read(key)
    if sequence.nil?
      sequence = find(sequence_friendly_id, conditions: ["campaign_id = #{a_campaign.id}"])
      Rails.cache.write(sequence.cache_key, sequence, expires_in: AppConstants.default_cache_timeout) if sequence
    end
    sequence
  end

  def self.generate_cache_key(a_campaign, sequence_friendly_id)
    "campaigns/#{a_campaign.friendly_id}/pagesequences/#{sequence_friendly_id}"
  end

  def cache_key
    self.class.generate_cache_key(self.campaign, self.friendly_id)
  end

  def landing_page
    action_pages.first
  end

  def first_taf(language)
    action_pages.collect {|action_page| action_page.tafs_for_locale(language)}.flatten.compact.first
  end

  def enable_language(language)
    enabled_languages << language.iso_code.to_s unless language_enabled?(language)
  end

  def disable_language(language)
    enabled_languages.delete language.iso_code.to_s
  end

  def language_enabled?(language)
    self.enabled_languages.include?(language.iso_code.to_s)
  end

  private

  def unique_name_within_campaign
    if campaign
      match = ActionSequence.where(campaign_id: campaign.id, name: name)
      self.errors.add(:name, "must be unique within a campaign") if match && match.any? { |m| m.id != id }
    end
  end

  def defaults
    self.email_subject ||= ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_SUBJECT']
    self.email_body ||= ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_BODY']
    self.tweet_text ||= ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_TWEET_TEXT']
    self.facebook_image ||= "http://#{AppConstants.host_uri}/#{ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_FACEBOOK_IMAGE']}"
    self.enabled_languages ||= []
  end
end
