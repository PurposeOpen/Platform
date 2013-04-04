module ListCutter
  class CountryRule < Rule
    fields :selected_by, :values
    validates_presence_of :selected_by, :message => 'Please choose the criteria'
    validates_presence_of :values, :message => 'Please choose values'

    def to_sql
      country_isos = Country.iso_codes_with(selected_by, values)

      sanitize_sql <<-SQL, @movement.id, country_isos
        SELECT id AS user_id FROM users
        WHERE movement_id = ?
        AND country_iso IN (?)
      SQL
    end

    def active?
      true
    end

    def can_negate?
      false
    end

    def to_human_sql
      case selected_by.to_s
        when 'name'
          "Country Name #{is_clause} any of these: #{values.join(", ")}"
        when 'region_id'
          "Country Region #{is_clause} any of these: #{Country.region_names_for_ids(values).join(", ")}"
        when 'commonwealth'
          "Country Common Wealth #{is_clause} #{values.first}"
      end
    end

  end
end
