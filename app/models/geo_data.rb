# == Schema Information
#
# Table name: geo_data
#
#  id          :integer          not null, primary key
#  country_iso :string(255)
#  postcode    :string(255)      not null
#  city        :string(255)
#  lat         :string(255)      not null
#  lng         :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class GeoData < ActiveRecord::Base
  attr_accessible :city, :country_iso, :lat, :lng, :postcode
  validates_presence_of :lat, :lng, :postcode, :city
  validates_uniqueness_of :postcode, scope: [:country_iso, :city]

  def country_name
    Country::COUNTRIES[self.country_iso.upcase][:name]
  end
end
