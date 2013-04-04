module ListCutter
  class OriginatingActionRule < Rule
    fields :page_ids, :movement_id

    POSSIBLE_MODULE_TYPES = ['PetitionModule', 'DonationModule', 'EmailTargetsModule', 'JoinModule']
    validates_presence_of :page_ids, :message => 'Please select one or more pages'
    validates_presence_of :movement_id, :message => 'Please specify the movement'

    def active?
      !page_ids.blank?
    end

    def to_sql
      sanitize_sql <<-SQL, movement_id, UserActivityEvent::Activity::SUBSCRIBED, page_ids
        SELECT user_id
        FROM user_activity_events
        WHERE movement_id = ?
        AND activity = ?
        AND page_id IN (?)
        GROUP BY user_id
      SQL
    end

    def to_human_sql
      names = ActionPage.where(movement_id: movement_id, id: page_ids).map(&:name).join(', ')
      "Originating Action #{is_clause} any of these: #{names}"
    end
  end
end
