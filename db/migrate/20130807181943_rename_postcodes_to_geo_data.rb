class RenamePostcodesToGeoData < ActiveRecord::Migration
  def self.up
    remove_index :postcodes, :zip
    rename_table :postcodes, :geo_data
  end 
  def self.down
    rename_table :geo_data, :postcodes
  end
end
