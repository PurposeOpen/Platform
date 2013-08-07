class RenameZipFromGeoDataToPostcode < ActiveRecord::Migration
  def change
    rename_column :geo_data, :zip, :postcode
  end
end
