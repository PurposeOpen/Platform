module ListCutter
  class ExternalActionTakenRule < Rule
    fields :action_slugs
    validates_presence_of :action_slugs, :message => 'Please specify the external action page slugs'

    def to_sql
      sanitize_sql <<-SQL, @movement.id, self.action_slugs
        SELECT user_id FROM external_activity_events
        WHERE movement_id = ?
        AND action_slug IN (?)
        GROUP BY user_id
      SQL
    end

    def active?
      !action_slugs.blank?
    end

    def to_human_sql
      "External action taken #{is_clause} any of these: #{action_slugs}"
    end

  end
end