class GeoData < ActiveRecord::Base
  attr_accessible :city, :country_iso, :lat, :lng, :postcode
  validates_presence_of :lat, :lng, :postcode, :city
  validates_uniqueness_of :postcode, scope: [:country_iso, :city]

  def country_name
    Country::COUNTRIES[self.country_iso.upcase][:name]
  end
end
