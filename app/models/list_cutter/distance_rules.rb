module ListCutter
  module DistanceRules
    EARTH_RADIUS = {miles: 3956, kilometers: 6371}
    DISTANCE_UNITS = ['kilometers', 'miles']

    def active?
      true
    end

    def can_negate?
      false
    end
  end
end