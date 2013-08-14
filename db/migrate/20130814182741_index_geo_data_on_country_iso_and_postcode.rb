class IndexGeoDataOnCountryIsoAndPostcode < ActiveRecord::Migration
  def change
    add_index "geo_data", ["country_iso", "postcode"]
  end
end
