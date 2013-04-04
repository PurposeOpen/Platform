class CreateAutofireEmails < ActiveRecord::Migration
  def change
    create_table :autofire_emails do |t|
      t.string :subject
      t.text :body
      t.boolean :enabled
      t.integer :action_page_id
      t.integer :language_id

      t.timestamps
    end
  end
end
