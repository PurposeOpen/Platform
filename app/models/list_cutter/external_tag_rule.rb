module ListCutter
  class ExternalTagRule < Rule
    fields :names

    def to_sql
      sanitize_sql <<-SQL, self.names, @movement.id
        SELECT external_activity_events.user_id FROM external_activity_events
        JOIN external_tags
        ON external_tags.name IN (?)
        AND external_tags.movement_id = ?
        JOIN external_actions_external_tags
        ON external_actions_external_tags.external_tag_id = external_tags.id
        JOIN external_actions
        ON external_actions_external_tags.external_action_id = external_actions.id
        WHERE external_activity_events.external_action_id = external_actions.id
        GROUP BY user_id
      SQL
    end

    def active?
      true
    end

    def to_human_sql
      "External tags #{is_clause} any of the following: #{names.join(', ')}"
    end

  end
end

