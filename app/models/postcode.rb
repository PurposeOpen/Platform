class Postcode < ActiveRecord::Base
  attr_accessible :city, :country, :lat, :lng, :zip
  validates_presence_of :lat, :lng, :zip
  validates_uniqueness_of :zip
end
