module ListCutter
  class DistanceFromPostcodeRule < Rule
    include ListCutter::DistanceRules

    fields :postcode, :country_iso, :distance, :distance_unit

    validates_presence_of :postcode, :distance
    validates_presence_of :country_iso, message: 'Please specify the country iso'
    validates_inclusion_of :distance_unit, in: DISTANCE_UNITS

    def initialize(attributes={})
      super
      @params[:postcode] = @params[:postcode].to_s
    end

    def to_sql
      center = GeoData.find_by_country_iso_and_postcode(self.country_iso, self.postcode)

      if center.nil?
        raise GeoDataNotFoundError, "could not find postcode #{self.postcode} for country #{self.country_iso}"
      end

      earth_radius = EARTH_RADIUS[self.distance_unit.to_sym]

      sanitize_sql <<-SQL, self.distance, @movement.id
        SELECT id AS user_id FROM users
        WHERE ('#{earth_radius}' * 2 * ASIN(SQRT( POWER(SIN(('#{center.lat}' - users.lat) *  pi()/180 / 2), 2) + COS('#{center.lat}' * pi()/180) * COS(users.lat * pi()/180) * POWER(SIN(('#{center.lng}' - users.lng) * pi()/180 / 2), 2) ))) <= ?
        AND users.movement_id = ?
        AND users.lat IS NOT NULL AND users.lat <> ''
        AND users.lng IS NOT NULL AND users.lng <> ''
      SQL
    end

    def to_human_sql
      "Members are within #{self.distance} #{self.distance_unit} of #{self.postcode}, #{self.country_iso.upcase}"
    end

  end
end