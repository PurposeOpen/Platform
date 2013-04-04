module ListCutter
  class MemberSourceRule < Rule
    fields :sources
    validates_presence_of :sources, :message => 'Please specify at least one source'

    def to_sql
      # User.where(["source #{operator} (?)", sources])
      sanitize_sql <<-SQL, @movement.id, sources
        SELECT id AS user_id FROM users
        WHERE movement_id = ?
        AND source IN (?)
      SQL
    end
    
    def active?
      !sources.nil? && !sources.empty?
    end

    def to_human_sql
      "Member source #{is_clause} any of these: #{sources.join(', ')}"
    end
  end
end
