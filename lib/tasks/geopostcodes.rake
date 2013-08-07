namespace :geopostcodes do
  task :import, [:url] => :environment do |t, args|
    CSV.parse(open(args[:url]), {col_sep: ";", headers: true}) do |row|
      puts row
      postcode = Postcode.find_or_initialize_by_zip_and_country(row[8], row[0])
      postcode.update_attributes(
        city:     row[9],
        lat:      row[12],
        lng:      row[13]
      )
    end
  end
end
