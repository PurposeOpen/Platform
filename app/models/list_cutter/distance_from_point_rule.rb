module ListCutter
  class DistanceFromPointRule < Rule
    include ListCutter::DistanceRules

    fields :lat, :lng, :distance, :distance_unit

    validates_presence_of :lat, :lng, :distance
    validates_inclusion_of :distance_unit, in: DISTANCE_UNITS

    def to_sql
      earth_radius = EARTH_RADIUS[self.distance_unit.to_sym]

      sanitize_sql <<-SQL, self.distance, @movement.id
        SELECT id AS user_id FROM users
        WHERE ('#{earth_radius}' * 2 * ASIN(SQRT( POWER(SIN(('#{self.lat}' - users.lat) *  pi()/180 / 2), 2) + COS('#{self.lat}' * pi()/180) * COS(users.lat * pi()/180) * POWER(SIN(('#{self.lng}' - users.lng) * pi()/180 / 2), 2) ))) <= ?
        AND users.movement_id = ?
        AND users.lat IS NOT NULL AND users.lat <> ''
        AND users.lng IS NOT NULL AND users.lng <> ''
      SQL
    end

    def to_human_sql
      "Members are within #{self.distance} #{self.distance_unit} of [lat: #{self.lat}, lng: #{self.lng}]"
    end

  end
end