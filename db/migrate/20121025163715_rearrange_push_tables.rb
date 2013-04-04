class RearrangePushTables < ActiveRecord::Migration
  def up
    create_push_table :push_sent_emails
    create_push_table :push_viewed_emails
    create_push_table :push_clicked_emails
    create_push_table :push_spammed_emails

    Push.pluck(:id).each  do |push_id|
      insert push_id, :push_sent_emails,    UserActivityEvent::Activity::EMAIL_SENT
      insert push_id, :push_viewed_emails,  UserActivityEvent::Activity::EMAIL_VIEWED
      insert push_id, :push_clicked_emails, UserActivityEvent::Activity::EMAIL_CLICKED
      insert push_id, :push_spammed_emails, UserActivityEvent::Activity::EMAIL_SPAMMED
    end
  end

  def down
    drop_table :push_sent_emails
    drop_table :push_viewed_emails
    drop_table :push_clicked_emails
    drop_table :push_spammed_emails
  end

  def create_push_table(table_name)
    create_table table_name, :id => false do |t|
      t.integer  :movement_id, :null => false
      t.integer  :user_id, :null => false
      t.integer  :push_id, :null => false
      t.integer  :email_id, :null => false
      t.datetime :created_at
    end
    add_index table_name, [:user_id, :movement_id, :created_at], :name => 'idx_list_cutter'
    add_index table_name, :push_id
  end

  def insert(push_id, table_name, activity)
    execute("INSERT INTO #{table_name.to_s}(movement_id, user_id, email_id, created_at, push_id)
      SELECT movements.id, p.user_id, p.email_id, p.created_at , #{push_id} as push_id from push_#{push_id} p
      JOIN pushes ON pushes.id = #{push_id}
      JOIN campaigns ON campaigns.id = pushes.campaign_id
      JOIN movements ON movements.id = campaigns.movement_id
      WHERE p.activity = '#{activity}' ")
  end
end
