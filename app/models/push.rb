# == Schema Information
#
# Table name: pushes
#
#  id          :integer          not null, primary key
#  campaign_id :integer
#  name        :string(255)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Push < ActiveRecord::Base
  include QuickGoable
  acts_as_paranoid

  belongs_to :campaign
  has_many :blasts, dependent: :destroy

  validates_length_of :name, maximum: 64, minimum: 3

  after_save ->{campaign.touch}

  delegate :movement, to: :campaign, allow_nil: true

  def self.activity_class_for(event)
    case event.to_sym
    when :email_sent
      PushSentEmail
    when :email_viewed
      PushViewedEmail
    when :email_clicked
      PushClickedEmail
    when :email_spammed
      PushSpammedEmail
    else
      nil
    end
  end

  # This method resorts to raw SQL for performance reasons
  # Using ActiveRecord to create events for all sent emails clocked in 22 minutes for 450_000 users
  # This methods allowed the same amount of users to be inserted in 11 seconds
  def batch_create_sent_activity_event!(user_ids, email, batch_size=10_000)
    insert_sql = "INSERT INTO #{PushSentEmail.table_name} (movement_id, user_id, push_id, email_id, created_at) VALUES "
    user_ids.each_slice(batch_size) do |slice|
      values = slice.inject([]) do |acc, user_id|
        acc << "(#{campaign.movement.id}, #{user_id}, #{self.id}, #{email.id}, UTC_TIMESTAMP())"
        acc
      end
      sql = insert_sql + values.join(',')
      self.connection.execute(sql)
    end
  end

  def count_by_activity(activity)
    event_class = Push.activity_class_for activity
    event_class.where(push_id: self.id).count
  end

  def self.log_activity!(activity, user, email)
    event_class = Push.activity_class_for activity
    event_class.create movement_id: email.movement.id, user_id: user.id, email_id: email.id, push_id: email.blast.push.id
  end

  def has_pending_jobs?
    blasts.any? &:has_pending_jobs?
  end
end
