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

require 'spec_helper'

describe GeoData do
  it { should validate_presence_of :lat }
  it { should validate_presence_of :lng }
  it { should validate_presence_of :postcode }
  it { should validate_presence_of :city }
  context "when lat and lng are set" do
    subject { GeoData.create lat: "12", lng: "42", postcode: "22280-020", city: "Rio de Janeiro" }
    it { should validate_uniqueness_of(:postcode).scoped_to(:country_iso, :city) }
  end
end
