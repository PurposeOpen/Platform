# == Schema Information
#
# Table name: autofire_emails
#
#  id             :integer          not null, primary key
#  subject        :string(255)
#  body           :text
#  enabled        :boolean
#  action_page_id :integer
#  language_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  from           :string(255)
#  reply_to       :string(255)
#

class AutofireEmail < ActiveRecord::Base
  belongs_to :action_page
  belongs_to :language

  after_initialize :defaults

  validates_uniqueness_of :action_page_id, :scope => :language_id

  warnings do
    validates_presence_of :subject, :if => :enabled
    validates_presence_of :body, :if => :enabled
    validates_presence_of :from, :if => :enabled
    validates_presence_of :reply_to, :if => :enabled
  end

  DEFAULT_SENDER = AppConstants.no_reply_address
  DEFAULT_SUBJECT = "Thanks for taking action!"
  DEFAULT_BODY = "Dear {NAME|Friend},\n\nThank you for taking action on this issue."

  def footer
    action_page.movement.footer_for_language(language.iso_code)
  end

  def movement
    action_page.movement
  end

  def html_body
    body
  end

  def plain_text_body
    body
  end

  def enabled_and_valid?
    self.enabled && self.valid?
  end

  def self.translated_defaults_map(movement)
    AutoFireEmailDefaults[movement.slug].nil? ? AutoFireEmailDefaults[:common] : AutoFireEmailDefaults[movement.slug]
  end

  private

  def defaults
    return if persisted?
    ask = action_page.try(:ask_module_for_language, language)
    #do not set default if ask module is not known.
    return if ask.nil?
    default_subject = ask.try(:default_autofire_subject, action_page.movement) || DEFAULT_SUBJECT
    default_body = ask.try(:default_autofire_body, action_page.movement) || DEFAULT_BODY
    default_sender = ask.try(:default_autofire_sender) || DEFAULT_SENDER

    self.enabled = true if self.enabled.nil?
    self.subject ||= default_subject
    self.body ||= default_body
    self.from ||= default_sender
    self.reply_to ||= (self.from || default_sender)
  end
end
