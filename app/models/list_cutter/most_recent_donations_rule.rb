module ListCutter
  class MostRecentDonationsRule < DateRule
    fields :donation_date, :operator
    validates_presence_of :donation_date, :message => 'Please specify a date for the most recent donations'
    validates_presence_of :operator, :message => 'Please select a filter criteria'

    def to_sql
      date = Date.strptime(donation_date, '%m/%d/%Y')

      sanitize_sql <<-SQL, @movement.id, date
        SELECT users.id
        FROM users
        INNER JOIN donations
        ON users.id = donations.user_id
        WHERE users.movement_id = ?
        AND donations.active = 1
        AND DATE(donations.created_at) #{query_operator} ?
        GROUP BY users.id
      SQL
    end

    def active?
      donation_date.present?
    end

    def can_negate?
      return false
    end

    def to_human_sql
      "Last donation date is #{operator} #{donation_date}"
    end
  end
end
