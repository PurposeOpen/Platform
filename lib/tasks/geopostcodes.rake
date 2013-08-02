namespace :geopostcodes do
  task :import, [:url] => :environment do |t, args|
    CSV.parse(open(args[:url]), {col_sep: ";", headers: true}) do |row|
      puts row
      Postcode.create(
        country:  row[0],
        zip:      row[8],
        city:     row[9],
        lat:      row[12],
        lng:      row[13]
      )
    end
  end
end
