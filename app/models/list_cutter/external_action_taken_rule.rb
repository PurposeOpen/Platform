module ListCutter
  class ExternalActionTakenRule < Rule
    fields :action_slugs
    validates_presence_of :action_slugs, :message => 'Please specify the external action page slugs'

    def to_sql
      sanitize_sql <<-SQL, @movement.id, self.action_slugs, ExternalActivityEvent::Activity::ACTION_TAKEN
        SELECT external_activity_events.user_id FROM external_activity_events
        INNER JOIN external_actions
        ON external_actions.movement_id = ?
        AND external_actions.action_slug IN (?)
        WHERE external_activity_events.activity = ?
        AND external_activity_events.external_action_id = external_actions.id
        GROUP BY external_activity_events.user_id
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
