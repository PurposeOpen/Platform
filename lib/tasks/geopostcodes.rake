namespace :geopostcodes do

  desc 'Import csv of data from geopostcodes.com'
  task :import, [:url] => :environment do |t, args|
    CSV.parse(open(args[:url]), {col_sep: ";", headers: true}) do |row|
      puts row
      postcode = GeoData.find_or_initialize_by_postcode_and_country_iso_and_city(row[8], row[0].downcase, row[9])
      postcode.update_attributes lat: row[12], lng: row[13]
    end
  end

  desc 'Set lat and lng on users'
  task :set_user_geo_data => :environment do
    User.find_each(conditions: 'country_iso IS NOT NULL AND postcode IS NOT NULL') do |user|
      if geodata = GeoData.find_by_country_iso_and_postcode(user.country_iso, user.postcode)
        user.update_attributes(lat: geodata.lat, lng: geodata.lng)
        puts "User #{user.id} updated: #{user.lat}, #{user.lng}"
      else
        Rails.logger.warn("Postcode \"#{user.postcode}\" for \"#{user.country_iso}\" not found.")
      end
    end
  end

end
