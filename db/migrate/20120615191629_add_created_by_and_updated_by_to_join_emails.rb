class AddCreatedByAndUpdatedByToJoinEmails < ActiveRecord::Migration
  def change
    add_column :join_emails, :created_by, :string
    add_column :join_emails, :updated_by, :string
  end
end
