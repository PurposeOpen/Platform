module ListCutter
  class ExternalActionRule < Rule
    fields :unique_action_slugs, :since, :activity

    validates_presence_of :unique_action_slugs, message: 'Please specify the external action page slugs'
    validates_presence_of :since, message: 'Please specify date'
    validates_inclusion_of :activity, in: ExternalActivityEvent::ACTIVITIES
    validates_each :since do |record, attr, value|
      record.errors.add attr, "can't be in the future" if value && Date.strptime(value, '%m/%d/%Y').future?
    end

    MAX_ACTION_SLUGS_TO_DISPLAY = 20

    def to_sql
      date = Date.strptime(since, '%m/%d/%Y')

      sanitize_sql <<-SQL, @movement.id, self.unique_action_slugs, self.activity, date
        SELECT external_activity_events.user_id FROM external_activity_events
        INNER JOIN external_actions
        ON external_actions.movement_id = ?
        AND external_actions.unique_action_slug IN (?)
        WHERE external_activity_events.activity = ?
        AND external_activity_events.created_at >= ?
        AND external_activity_events.external_action_id = external_actions.id
        GROUP BY external_activity_events.user_id
      SQL
    end

    def active?
      !unique_action_slugs.blank?
    end

    def to_human_sql
      slugs = (unique_action_slugs.length > MAX_ACTION_SLUGS_TO_DISPLAY) ? "#{unique_action_slugs.length} actions (too many to list)" : unique_action_slugs

      "External #{activity.titleize.downcase} #{is_clause} any of the following since #{since}: #{slugs}"
    end

  end
end
