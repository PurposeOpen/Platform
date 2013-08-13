module ListCutter
  class PostcodeRule < Rule
    fields :postcode, :country_iso

    def to_sql
      sanitize_sql <<-SQL, self.postcode, self.country_iso, @movement.id
        SELECT users.id AS user_id FROM users
        WHERE users.postcode = ? AND users.country_iso = ? AND users.movement_id = ?
      SQL
    end

    def active?
      true
    end

    def to_human_sql
      "Postal code #{is_clause} #{self.postcode}"
    end
  end
end
