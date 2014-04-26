class GeolocationService
  module User
    def self.included(base)
      base.class_eval do
        geocoded_by :address, latitude: :lat, longitude: :lng
        include CountryHelper
      end
    end

    def address 
      [street_address, suburb, postcode, country_full_name].compact.join(', ')
    end

    def country_full_name 
      country_name(country_iso, 'en')
    end

  end

  delegate :address, :postcode, :country_iso, :lat, :lng, :geocode, to: :user

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def lookup
    set_geolocation
    set_timezone unless AppConstants.geomaps_username.blank? 
  end

  def set_geolocation
    return unless address.present?
    if postcode.present? && country_iso.present?
      if geodata = GeoData.find_by_country_iso_and_postcode(country_iso, postcode)
        @user.lat, @user.lng = geodata.lat, geodata.lng
      else
        Rails.logger.warn("Postcode \"#{postcode}\" for \"#{country_iso}\" not found.")
      end
    end
    geocode if lat.nil? || lng.nil?
  end

  def set_timezone
    return unless lat && lng
    timezone = Timezone::Zone.new latlon: [lat, lng]
    @user.time_zone = timezone.zone 
  rescue  Timezone::Error::NilZone => e
    @user.time_zone = nil
  end

end
