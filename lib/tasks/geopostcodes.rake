namespace :geopostcodes do
  task :import, :url do |t, args|
    CSV.parse(open(args[:url]), {:col_sep => ";"}) do |row|
      
    end
  end
end
