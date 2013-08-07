class RenamePostcodesToGeoData < ActiveRecord::Migration
  def self.up
    rename_table :postcodes, :geo_data
  end 
  def self.down
    rename_table :geo_data, :postcodes
  end
end
