class AddPushBounceEmails < ActiveRecord::Migration
  def up
    table_name='push_bounced_emails'
  
    create_table table_name, :id => false do |t|
      t.integer  :movement_id, :null => false
      t.integer  :user_id, :null => false
      t.integer  :push_id, :null => false
      t.integer  :email_id, :null => false
      t.datetime :created_at
    end
    add_index table_name, [:user_id, :movement_id, :created_at], :name => 'idx_list_cutter'
    add_index table_name, :push_id
    add_index table_name, [:movement_id, :email_id]
    add_index table_name, [:movement_id, :push_id]
  end

  def down
  end
end