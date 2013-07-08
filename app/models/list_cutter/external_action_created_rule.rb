module ListCutter
  class ExternalActionCreatedRule < Rule
    fields :sources, :since

    validates_presence_of :sources, :message => 'Please specify sources'
    validates_presence_of :since, :message => 'Please specify date'
    validates_each :since do |record, attr, value|
      record.errors.add attr, "can't be in the future" if value && Date.strptime(value, '%m/%d/%Y').future?
    end

    def to_sql
      date = Date.strptime(since, '%m/%d/%Y')

      sanitize_sql <<-SQL, self.sources, @movement.id, ExternalActivityEvent::Activity::ACTION_CREATED, date
        SELECT external_activity_events.user_id FROM external_activity_events
        INNER JOIN external_actions
        ON external_actions.source IN (?)
        AND external_actions.movement_id = ?
        WHERE external_activity_events.activity = ?
        AND external_activity_events.created_at >= ?
        AND external_activity_events.external_action_id = external_actions.id
        GROUP BY user_id
      SQL
    end

    def active?
      !sources.blank?
    end

    def to_human_sql
      activity_clause = negate? ? 'Did not create' : 'Created'
      "#{activity_clause} an action via any of the following sources since #{since}: #{sources}"
    end

  end
end
