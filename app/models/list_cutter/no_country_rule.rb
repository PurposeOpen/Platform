module ListCutter
  class NoCountryRule < Rule
    def to_sql
      sanitize_sql <<-SQL, @movement.id
        SELECT id AS user_id FROM users
        WHERE movement_id = ? AND country_iso IS NULL
      SQL
    end
    def active?
      true
    end
    def to_human_sql
      "User has No Country (country_iso is null)"
    end
  end
end
