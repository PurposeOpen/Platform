class AddJoinEmailSentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :join_email_sent, :boolean
  end
end
