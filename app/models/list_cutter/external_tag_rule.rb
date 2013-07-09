module ListCutter
  class ExternalTagRule < Rule
    fields :names

    def to_sql
      sanitize_sql <<-SQL, self.names
        SELECT external_activity_events.user_id FROM external_activity_events
        JOIN external_tags
        ON external_tags.name IN (?)
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
  end
end

