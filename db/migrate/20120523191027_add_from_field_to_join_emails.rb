class AddFromFieldToJoinEmails < ActiveRecord::Migration
  def change
    add_column :join_emails, :from, :string
  end
end
