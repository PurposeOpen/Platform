class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.string :country
      t.string :zip, null: false
      t.string :city
      t.string :lat, null: false
      t.string :lng, null: false

      t.timestamps
    end
    add_index :postcodes, :zip, :unique => true
  end
end
