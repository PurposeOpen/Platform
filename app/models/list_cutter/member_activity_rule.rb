module ListCutter
  class MemberActivityRule < ActivityCountRule

    ACTIVITY_MODULES = {
      'Petition' => PetitionModule.name,
      'Donation' => DonationModule.name,
      'Email A Target' => EmailTargetsModule.name,
      'Join' => JoinModule.name
    }

    fields :activity_count_operator, :activity_count, :activity_module_types, :activity_since_date
    alias_method :range_operator, :activity_count_operator

    validates_presence_of [:activity_count_operator, :activity_count, :activity_module_types, :activity_since_date]
    validates_inclusion_of :activity_count_operator, in: lambda { |_| OPERATORS.map(&:last) }
    validates_numericality_of :activity_count, only_integer: true, greater_than_or_equal_to: 0

    validates_each :activity_module_types do |record, attr, value|
      record.errors.add(attr, 'is not included in the list') if value && (value - ACTIVITY_MODULES.values.map(&:to_s)).present?
    end

    validates_each :activity_since_date do |record, attr, value|
      record.errors.add attr, "can't be in the future" if value && Date.strptime(value, '%m/%d/%Y').future?
    end

    def all_activity_module_types
      ACTIVITY_MODULES.to_a
    end

    def to_sql
      date = Date.strptime(activity_since_date, '%m/%d/%Y')

      sanitize_sql <<-SQL, activity_module_types, date, @movement.id
        SELECT uae.user_id, COUNT(uae.user_id) AS activity_count
        FROM user_activity_events uae
        WHERE uae.content_module_type IN (?)
        AND uae.created_at >= ?
        AND uae.movement_id = ?
        GROUP BY uae.user_id
      SQL
    end

    def to_human_sql
      "Member Activity #{is_clause} #{range_operator.titleize} #{activity_count} actions in any of these: #{activity_module_types.join(', ')} since #{activity_since_date}"
    end
  end
end
