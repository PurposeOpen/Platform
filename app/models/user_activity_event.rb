# == Schema Information
#
# Table name: user_activity_events
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  activity            :string(64)       not null
#  campaign_id         :integer
#  action_sequence_id  :integer
#  page_id             :integer
#  content_module_id   :integer
#  content_module_type :string(64)
#  user_response_id    :integer
#  user_response_type  :string(64)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_id            :integer
#  push_id             :integer
#  movement_id         :integer
#  comment             :string(255)
#  comment_safe        :boolean
#

class UserActivityEvent < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include CountryHelper

  belongs_to :user
  belongs_to :campaign
  belongs_to :action_sequence
  belongs_to :page
  belongs_to :email
  belongs_to :push
  belongs_to :content_module
  belongs_to :movement
  belongs_to :user_response, :polymorphic => true

  before_validation :profanalyze_comment
  before_save :denormalize

  validates_presence_of :user_id
  validates_uniqueness_of :activity, :scope => [:user_id, :email_id],
      :if => Proc.new { |uae| uae.activity == Activity::EMAIL_VIEWED }

  DEFAULT_EVENT_LIMIT = 20
  module Activity
    ACTION_TAKEN = :action_taken
    SUBSCRIBED = :subscribed
    EMAIL_CLICKED = :email_clicked
    EMAIL_VIEWED = :email_viewed
    EMAIL_SENT = :email_sent
    UNSUBSCRIBED = :unsubscribed
    EMAIL_SPAMMED = :email_spammed
  end

  scope :actions_taken, where(:activity => Activity::ACTION_TAKEN)
  scope :subscriptions, where(:activity => Activity::SUBSCRIBED)
  scope :unsubscriptions, where(:activity => Activity::UNSUBSCRIBED)

  scope :emails_sent, where(:activity => Activity::EMAIL_SENT)
  scope :emails_viewed, where(:activity => Activity::EMAIL_VIEWED)
  scope :emails_clicked, where(:activity => Activity::EMAIL_CLICKED)
  scope :emails_spammed, where(:activity => Activity::EMAIL_SPAMMED)
  scope :actions_taken_for_sequence, (proc do |action_sequence|
        actions_taken.includes([{:user => :language}, :page, :action_sequence]).where(:action_sequence_id => action_sequence.id)
      end)

  def activity
    read_attribute(:activity).to_sym
  end

  def self.load_feed(movement, language, page_id, after_time, only_with_comments=false)
    query = %Q{
      SELECT uae.* FROM (

        SELECT *
        FROM user_activity_events
        WHERE
          movement_id=#{movement.id}
          AND (activity='action_taken' OR activity='subscribed')
    }
    query << %Q{
          AND page_id=#{page_id}
    } if page_id.present?

    query << %Q{
          AND created_at > '#{Time.parse(after_time).to_s(:db)}'
    } if after_time.present? && after_time != "null"

    query << %Q{
          AND comment IS NOT NULL AND comment != '' AND comment_safe=true
    } if page_id.present? && only_with_comments

    query << %Q{
        ORDER BY created_at DESC
        LIMIT 1000

      ) AS uae
      LEFT OUTER JOIN users ON users.id=uae.user_id
      LEFT OUTER JOIN action_sequences ON action_sequences.id=uae.action_sequence_id
      WHERE
        users.name_safe=true
        AND (
          (uae.activity='action_taken' AND action_sequences.published=true AND action_sequences.enabled_languages LIKE '%#{language.iso_code}%')
    }
    query << %Q{
          OR (uae.activity='subscribed' AND (uae.content_module_type IS NULL OR content_module_type='JoinModule') AND users.first_name IS NOT NULL AND users.first_name <> '')
    } if movement.subscription_feed_enabled
    query << %Q{
        )
      LIMIT #{DEFAULT_EVENT_LIMIT};
    }

    UserActivityEvent.find_by_sql(query)
  end

  def self.subscribed!(user, email=nil, page=nil, content_module=nil)
    create!(
      :activity => Activity::SUBSCRIBED,
      :user => user,
      :content_module => content_module,
      :email => email,
      :page => page
    )
  end

  def self.action_taken!(user, page, content_module, user_response, email, comment=nil)
    create!(
      :activity => Activity::ACTION_TAKEN,
      :user => user,
      :content_module => content_module,
      :page => page,
      :user_response => user_response,
      :email => email,
      :push => email.try(:blast).try(:push),
      :comment => comment
    )
  end

  def self.email_clicked!(user, email, page=nil)
    self.email_viewed!(user, email)
    Push.log_activity!(:email_clicked, user, email)
  end

  def self.email_spammed!(user, email)
    Push.log_activity!(:email_spammed, user, email)
  end

  def self.email_viewed!(user, email)
    Push.log_activity!(:email_viewed, user, email)
  end

  def self.unsubscribed!(user, email=nil)
    create!(
      :activity => Activity::UNSUBSCRIBED,
      :user => user,
      :email => email
    )
  end

  # TODO bg: translate and deal with hosting/attendance events.
  def public_stream_html(opts = {})
    language = opts[:language]

    case activity
    when Activity::SUBSCRIBED
      join_page = movement.join_page
      join_page.ask_module.public_activity_stream_html(self.user, join_page, language)
    when Activity::ACTION_TAKEN
      self.content_module.public_activity_stream_html(self.user, self.page, language)
    when Activity::EMAIL_CLICKED
      member_name "Member", "clicked a link in the #{self.email.name} email."
    when Activity::EMAIL_VIEWED
      member_name "Member", "opened the #{self.email.name} email."
    when Activity::UNSUBSCRIBED
      member_name "Member", "unsubscribed from #{self.movement.name}!"
    end
  end

  def member_name(default, text)
    "<span class=\"name\">#{self.user.greeting || default}</span> #{text}"
  end
  private :member_name

  def as_json(opts = {})
    {
      :id => id,
      :html => public_stream_html(opts),
      :timestamp => created_at.httpdate,
      :timestamp_in_words => time_ago_in_words(created_at),
      :comment => comment,
      :first_name => user.first_name,
      :last_name => user.last_name,
      :country_iso => user.country_iso,
      :country => user.country_iso ? country_name(user.country_iso, opts[:language].iso_code).titleize : ''
    }
  end

  def to_row
    [created_at, action_sequence.name, page.name, content_module_type.to_s.sub('Module',''), user.language_iso_code,
      user.email, user.first_name, user.last_name, user.name_safe, user.country_iso_code, user.postcode, user.mobile_number,
      comment, comment_safe]
  end

  private

  def denormalize
    if content_module.present?
      self.content_module_type = content_module.class.name
    end

    if page.present? && page.is_a?(ActionPage)
      self.action_sequence = page.action_sequence
      self.campaign = action_sequence.campaign
      self.movement = campaign.movement
    end

    if movement.blank?
      self.movement = user.movement
    end
  end

  def profanalyze_comment
    self.comment_safe = !(Profanalyzer.profane?(self.comment) || (self.comment =~ /http|www|url/))
    return true
  end
end
