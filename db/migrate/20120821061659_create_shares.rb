class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :share_type
      t.integer :user_id
      t.integer :campaign_id
      t.integer :page_id

      t.timestamps
    end

    add_index :shares, :page_id
  end
end
