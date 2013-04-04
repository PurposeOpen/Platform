class CreateJoinEmails < ActiveRecord::Migration
  def change
    create_table :join_emails do |t|
      t.string :subject
      t.string :body
      t.integer :movement_locale_id

      t.timestamps
    end
  end
end
