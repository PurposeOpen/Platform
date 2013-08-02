class Postcode < ActiveRecord::Base
  attr_accessible :city, :country, :lat, :lng, :zip
end
