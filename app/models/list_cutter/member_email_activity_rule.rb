module ListCutter
  class MemberEmailActivityRule < ListCutter::ActivityCountRule

    ACTIVITY_TYPES_HASH = {
      'Sent' => UserActivityEvent::Activity::EMAIL_SENT,
      'Opened' => UserActivityEvent::Activity::EMAIL_VIEWED,
      'Clicked' => UserActivityEvent::Activity::EMAIL_CLICKED
    }

    fields :range_operator, :activity_count, :activity_type, :since_date

    validates_presence_of [:range_operator, :activity_count, :activity_type, :since_date]
    validates_inclusion_of :range_operator, in: lambda { |rule| OPERATORS.map(&:last) }
    validates_numericality_of :activity_count, only_integer: true, greater_than_or_equal_to: 0
    validates_each :since_date do |record, attr, value|
      record.errors.add(attr, "can't be in future") if value && Date.strptime(value, '%m/%d/%Y').future?
    end

    def all_activity_types
      ACTIVITY_TYPES_HASH.to_a
    end

    def to_sql
      date = Date.strptime(since_date, '%m/%d/%Y')
      activity_table = Push.activity_class_for(activity_type).table_name

      sanitize_sql <<-SQL, date, @movement.id
        SELECT activity_table.user_id, COUNT(activity_table.user_id) AS activity_count
        FROM #{activity_table} activity_table
        USE INDEX (idx_list_cutter)
        WHERE activity_table.created_at >= ?
        AND activity_table.movement_id = ?
        GROUP BY activity_table.user_id
      SQL
    end

    def to_human_sql
      email_activity = ACTIVITY_TYPES_HASH.key(activity_type.to_sym)
      "Member Email Activity #{is_clause} #{range_operator.titleize} #{activity_count} emails #{email_activity} since #{since_date}"
    end
  end
end
