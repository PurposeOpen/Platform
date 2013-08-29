class CreateEmailRecipientDetails < ActiveRecord::Migration
  def change
    create_table :email_recipient_details do |t|
      t.integer :email_id
      t.integer :recipients_count
      t.text :sent_to_users_ids
      t.timestamps
    end
  end
end
