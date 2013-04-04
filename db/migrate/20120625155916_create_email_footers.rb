class CreateEmailFooters < ActiveRecord::Migration
  def change
    create_table :email_footers do |t|
      t.text :content
      t.integer :movement_locale_id
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
