class GeoData < ActiveRecord::Base
  attr_accessible :city, :country, :lat, :lng, :postcode
  validates_presence_of :lat, :lng, :postcode, :city
  validates_uniqueness_of :postcode, scope: [:country, :city]
end
