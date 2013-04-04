class AddReplyToToEmailTables < ActiveRecord::Migration
  def change
    add_column :autofire_emails, :reply_to, :string
    add_column :join_emails, :reply_to, :string
    add_column :emails, :reply_to, :string
  end
end
