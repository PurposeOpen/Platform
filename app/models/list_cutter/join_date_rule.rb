module ListCutter
  class JoinDateRule < DateRule
    fields :join_date, :operator
    validates_presence_of :join_date, :message => 'Please specify a join date'
    validates_presence_of :operator, :message => 'Please select a filter criteria'

    def to_sql
      date = Date.strptime(join_date, '%m/%d/%Y')

      sanitize_sql <<-SQL, @movement.id, date
        SELECT id AS user_id FROM users
        WHERE movement_id = ?
        AND DATE(created_at) #{query_operator} ?
      SQL
    end

    def active?
      !join_date.blank?
    end

    def can_negate?
      return false
    end

    def to_human_sql
      "Join Date is #{operator} #{join_date}"
    end

  end
end
