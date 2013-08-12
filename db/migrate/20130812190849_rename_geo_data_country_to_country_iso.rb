class RenameGeoDataCountryToCountryIso < ActiveRecord::Migration
  def change
    rename_column :geo_data, :country, :country_iso
  end
end
