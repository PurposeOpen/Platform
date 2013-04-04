module ListCutter
  class ZoneRule < Rule
    fields :zone_code
    validates_presence_of :zone_code, :message => 'Please specify a zone code'

    def to_sql
      sanitize_sql <<-SQL, @movement.id, Country.countries_in_zone(zone_code)
        SELECT id AS user_id FROM users
        WHERE movement_id = ? AND country_iso IN (?)
      SQL
    end

    def active?
      !zone_code.blank?
    end

    def to_human_sql
      "Zone #{is_clause} #{zone_code}"
    end

  end
end
