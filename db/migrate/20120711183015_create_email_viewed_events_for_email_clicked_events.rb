class UserActivityEvent < ActiveRecord::Base
 belongs_to :email

  module Activity
    EMAIL_CLICKED = :email_clicked
    EMAIL_VIEWED = :email_viewed
  end
end

class CreateEmailViewedEventsForEmailClickedEvents < ActiveRecord::Migration
  def up
    UserActivityEvent.where(:activity => UserActivityEvent::Activity::EMAIL_CLICKED).each do |uae|
      unless UserActivityEvent.where(:activity => UserActivityEvent::Activity::EMAIL_VIEWED,
          :user_id => uae.user_id, :email_id => uae.email_id).any?

        email_viewed_push_records = ActiveRecord::Base.connection.execute("SELECT * FROM push_#{uae.email.blast.push.id} WHERE email_id = #{uae.email_id} AND user_id = #{uae.user_id} AND activity = '#{UserActivityEvent::Activity::EMAIL_VIEWED}'")
        unless email_viewed_push_records.to_a.present?
          ActiveRecord::Base.connection.execute("INSERT INTO push_#{uae.email.blast.push.id} (user_id, email_id, activity, created_at) VALUES (#{uae.user_id}, #{uae.email_id}, '#{UserActivityEvent::Activity::EMAIL_VIEWED}', '#{uae.created_at}')")
        end

        UserActivityEvent.create!(:activity => UserActivityEvent::Activity::EMAIL_VIEWED,
            :user_id => uae.user_id, :email_id => uae.email_id)
      end
    end
  end

  def down
  end
end
