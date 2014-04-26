require "spec_helper"

describe GeolocationService do
  let(:geolocation_service) { GeolocationService.new(@user) }
  describe 'geolocation', :geolocate do 
    describe "#set_geolocation" do
      context 'no purchased GeoData information' do
        it 'uses geocoder service to find lat and lng' do
          @user = FactoryGirl.build(:user, street_address: 'Wherever')
          @user.should_receive(:geocode)
          geolocation_service.set_geolocation
        end
      end

      context 'purchased GeoData information exists' do
        let(:postcode) { stub_model(GeoData, lat: "45.0", lng: "45.0") }
        before { GeoData.stub(:find_by_country_iso_and_postcode).with("br", "123456").and_return(postcode) }

        context "when the user has a postcode and country_iso" do
          it "should set latitude and longitude using GeoData" do
            @user = FactoryGirl.build(:user, postcode: "123456", country_iso: "br")
            geolocation_service.set_geolocation
            expect([@user.lat, @user.lng]).to eq(["45.0","45.0"])
          end

          context "when there is no corresponding postcode" do
            before do
              GeoData.stub(:find_by_country_iso_and_postcode)
                     .with("br", "123456").and_return(nil)
              User.any_instance.stub(:geocode)
            end

            it "it should log the missing postcode/country" do
              @user = FactoryGirl.build(:user, postcode: "123456", country_iso: "br")
              Rails.logger.should_receive(:warn).with("Postcode \"123456\" for \"br\" not found.")
              geolocation_service.set_geolocation
            end

            it "defers to geocoding" do
              @user = FactoryGirl.build(:user, postcode: "123456", country_iso: "br")
              @user.should_receive(:geocode).once
              geolocation_service.set_geolocation
            end
          end
        end

        context "when the user doesn't have an address" do
          it "should not set latitude and longitude" do
            @user = FactoryGirl.build(:user, postcode: nil, street_address: nil, 
                                     country_iso: nil, suburb: nil) 
            geolocation_service.set_geolocation
            expect([@user.lat, @user.lng]).to eq([nil, nil])
          end
        end

      end
    end

    describe "#set_timezone" do 
      it "sets user's timezone based on lat and lng" do
        zone = double(:zone, zone: 'Twilight Zone')
        @user = FactoryGirl.build(:user, lat: '12', lng: '24')
        Timezone::Zone.should_receive(:new).with(latlon: ['12', '24']).and_return(zone)
        geolocation_service.set_timezone
        expect(@user.time_zone).to eq('Twilight Zone')
      end
    end

    describe 'geolocation callback api integration', :vcr do
      context 'when user has only entered their country' do
        let(:user) { FactoryGirl.build(:user, country_iso: 'us') }
        before { GeolocationService.new(user).lookup }

        it 'sets general latitude and longitude using geocoding' do
          expect([user.lat, user.lng]).to eq([38.0, -97.0])
        end

        it 'sets reasonable timezone for country' do
          expect(user.time_zone).to include('America')
        end
      end

      context 'when complete address is given' do 
        let(:user) do
          FactoryGirl.build(:user, street_address: '8 Another Way', 
                             suburb: 'Black Mountain', 
                             country_iso: 'us', 
                             postcode: '28711')
        end
        before { GeolocationService.new(user).lookup }

        it 'sets precise lat and lng for user' do
          expect([user.lat, user.lng]).to eq([35.6179, -82.32123])
        end

        it "sets user's timezone based on lat and lng" do
          expect(user.time_zone).to eq('America/New_York')
        end
      end

      it 'leaves timezone blank if there is an error' do
        Timezone::Configure.stub(:username).and_return('false-username')
        user = FactoryGirl.build(:user, country_iso: 'us')
        GeolocationService.new(user).lookup 
        expect(user.time_zone).to eq(nil)
      end

      it 'does not set timezone when username is not set' do
        AppConstants.stub(:geomaps_username).and_return(nil)
        user = FactoryGirl.build(:user, country_iso: 'us')
        geolocation_service = GeolocationService.new(user)
        geolocation_service.should_not_receive(:set_timezone)
        geolocation_service.lookup
      end
    end
  end
end
