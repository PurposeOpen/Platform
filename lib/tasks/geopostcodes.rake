namespace :geopostcodes do
  task :import, [:url] => :environment do |t, args|
    CSV.parse(open(args[:url]), {col_sep: ";", headers: true}) do |row|
      puts row
      postcode = GeoData.find_or_initialize_by_postcode_and_country_iso_and_city(row[8], row[0].downcase, row[9])
      postcode.update_attributes lat: row[12], lng: row[13]
    end
  end
end
