module ListCutter
  class RecurringDonationsRule < Rule
    fields :recurring_donations, :status
    validates_presence_of :status, :message => 'Please select a donation status'

    def to_sql
      sanitize_sql <<-SQL, @movement.id, status
        SELECT users.id
        FROM users
        INNER JOIN donations
        ON users.id = donations.user_id
        WHERE users.movement_id = ?
        AND donations.active = ?
        GROUP BY users.id
      SQL
    end

    def active?
      recurring_donations.present?
    end

    def can_negate?
      false
    end

    def to_human_sql
      "Donation status is #{status}"
    end
  end
end
