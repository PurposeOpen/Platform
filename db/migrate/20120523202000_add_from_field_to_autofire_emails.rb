class AddFromFieldToAutofireEmails < ActiveRecord::Migration
  def change
    add_column :autofire_emails, :from, :string
  end
end
