class RemoveCreatedAtFromUniqueActivityByEmails < ActiveRecord::Migration
  def up
    remove_column :unique_activity_by_emails, :created_at
  end

  def down
    add_column :unique_activity_by_emails, :created_at, :datetime
  end
end
