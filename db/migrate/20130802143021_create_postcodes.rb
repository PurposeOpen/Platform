class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.string :country
      t.string :zip
      t.string :city
      t.string :lat
      t.string :lng

      t.timestamps
    end
  end
end
