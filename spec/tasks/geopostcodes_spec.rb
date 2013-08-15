require 'spec_helper'
require 'rake'

describe 'set_user_geo_data' do
  after :all do
    User.delete_all
    GeoData.delete_all
  end

  def run_set_user_geo_data
    rake = Rake::Application.new
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load "#{Rails.root}/lib/tasks/geopostcodes.rake"
    rake["geopostcodes:set_user_geo_data"].invoke
  end

  context "user's geodata is found in the geo_data table" do

    it 'should set lat and lng for users' do
      geo_data_attributes = {lat: '40.75794', lng: '-73.99040', country_iso: 'us', city: 'New York', postcode: '10036'}
      user = create(:user, country_iso: geo_data_attributes[:country_iso], postcode: geo_data_attributes[:postcode])
      GeoData.create(geo_data_attributes)

      run_set_user_geo_data

      user.reload
      user.lat.should == geo_data_attributes[:lat]
      user.lng.should == geo_data_attributes[:lng]
    end

  end

  context "user's geodata is not found in the geo_data table" do

    it 'should log a warning' do
      user = create(:user, country_iso: 'us', postcode: '99999')
      Rails.logger.should_receive(:warn).with("Postcode \"#{user.postcode}\" for \"#{user.country_iso}\" not found.")

      run_set_user_geo_data
    end

  end

end