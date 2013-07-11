# == Schema Information
#
# Table name: unique_activity_by_emails
#
#  id          :integer          not null, primary key
#  email_id    :integer
#  activity    :string(64)
#  total_count :integer
#  updated_at  :datetime         not null
#

# This is an aggregation table created for performance reasons
# It consists of push-related stats
#
class UniqueActivityByEmail < ActiveRecord::Base
  def self.update!
    only_events_created_after = self.last_updated_time
    time_now = Time.now.utc.to_s(:db)

    update_other_activities only_events_created_after, time_now
    update_email_activities only_events_created_after, time_now
  end

  def self.reset!
    delete_all
    update!
  end

  private

  def self.update_other_activities(last_updated_at, time_now)
    sql = <<-SQL
      INSERT INTO `#{self.table_name}` (email_id, activity, total_count, updated_at)
      SELECT email_id, activity, COUNT(DISTINCT email_id, activity, user_id) as count, '#{time_now}'
        FROM `#{UserActivityEvent.table_name}`
        WHERE email_id IS NOT NULL
        AND activity NOT IN ('email_viewed', 'email_sent', 'email_clicked', 'email_spammed')
        AND created_at > '#{last_updated_at}'
        GROUP BY email_id, activity
        ON DUPLICATE KEY UPDATE total_count = total_count + VALUES(total_count), updated_at = '#{time_now}';
    SQL

    self.connection.execute(sql)
  end

  def self.pushes_with_emails_in_last_30_days(time_now)
    Push.find_by_sql <<-SQL
      SELECT *
      FROM #{Push.table_name}
      WHERE id IN (
        SELECT DISTINCT(p.id)
        FROM `#{Push.table_name}` p
        JOIN `#{Blast.table_name}` b ON b.push_id = p.id
        JOIN `#{Email.table_name}` e ON e.blast_id = b.id
        WHERE e.updated_at > TIMESTAMP('#{time_now}') - INTERVAL 30 day
      )
    SQL
  end

  def self.update_email_activities(last_updated_at, time_now)
    pushes_with_emails_in_last_30_days(time_now).each do |push|
      update_email_activities_by_push(push, last_updated_at, time_now)
    end
  end

  def self.update_email_activities_by_push(push, last_updated_at, time_now)
    self.connection.execute query_for_activity_stats_by_push(push.id, last_updated_at, time_now, UserActivityEvent::Activity::EMAIL_SENT)
    self.connection.execute query_for_activity_stats_by_push(push.id, last_updated_at, time_now, UserActivityEvent::Activity::EMAIL_VIEWED)
    self.connection.execute query_for_activity_stats_by_push(push.id, last_updated_at, time_now, UserActivityEvent::Activity::EMAIL_CLICKED)
    self.connection.execute query_for_activity_stats_by_push(push.id, last_updated_at, time_now, UserActivityEvent::Activity::EMAIL_SPAMMED)
  end

  def self.query_for_activity_stats_by_push(push_id, last_updated_at, time_now, activity)
    "INSERT INTO #{self.table_name} (email_id, activity, total_count, updated_at)
     SELECT email_id, '#{activity.to_s}', count(distinct email_id, user_id) as count, '#{time_now}'
     FROM #{Push.activity_class_for(activity).table_name}
     WHERE push_id = #{push_id}
     AND created_at > '#{last_updated_at}'
     GROUP BY email_id
     ON DUPLICATE KEY UPDATE total_count = total_count + VALUES(total_count), updated_at = '#{time_now}';"
  end

  def self.last_updated_time
    result = select("MAX(updated_at) AS updated_at").first.try(:updated_at) || Time.at(0)
    result.to_formatted_s(:db)
  end
end
