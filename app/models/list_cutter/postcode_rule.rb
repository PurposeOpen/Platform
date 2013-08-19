module ListCutter
  class PostcodeRule < Rule
    fields :postcodes, :country_iso

    def to_sql
      sanitize_sql <<-SQL, self.postcodes.split(","), self.country_iso, @movement.id
        SELECT users.id AS user_id FROM users
        WHERE users.postcode IN (?) AND users.country_iso = ? AND users.movement_id = ?
      SQL
    end

    def active?
      true
    end

    def to_human_sql
      "Postal code is #{self.postcodes.gsub(",", " or ")}"
    end

    def can_negate?
      false
    end
  end
end
