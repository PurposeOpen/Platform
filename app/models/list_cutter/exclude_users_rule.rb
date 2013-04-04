module ListCutter
  class ExcludeUsersRule < Rule
    fields :push_id

    def to_sql
      push_events_table = Push.activity_class_for(UserActivityEvent::Activity::EMAIL_SENT).table_name

      sanitize_sql <<-SQL, @movement.id, push_id
        SELECT users.id AS user_id FROM users
        WHERE users.id NOT IN (
          SELECT DISTINCT events.user_id FROM #{push_events_table} events
          WHERE events.movement_id = ?
          AND events.push_id = ?
        )
      SQL
    end
  end
end
