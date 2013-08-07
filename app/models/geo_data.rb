class GeoData < ActiveRecord::Base
  attr_accessible :city, :country, :lat, :lng, :postcode
  validates_presence_of :lat, :lng, :postcode
  validates_uniqueness_of :postcode, scope: [:country]
end
