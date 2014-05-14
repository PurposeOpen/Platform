module ListCutter
  class ActionTakenRule < Rule
    fields :page_ids
    validates_presence_of :page_ids, message: 'Please specify the page ids'
    POSSIBLE_MODULE_TYPES = ['PetitionModule', 'DonationModule', 'EmailTargetsModule', 'JoinModule']

    def to_sql
      activities = [ UserActivityEvent::Activity::ACTION_TAKEN, UserActivityEvent::Activity::SUBSCRIBED ]
      ids = self.page_ids.map(&:to_i)

      sanitize_sql <<-SQL, @movement.id, activities, ids
        SELECT user_id FROM user_activity_events
        WHERE movement_id = ?
        AND activity IN (?) 
        AND page_id IN (?)
        GROUP BY user_id
      SQL
    end

    def active?
      !page_ids.blank?
    end

    def to_human_sql
      page_names = ActionPage.where(id: page_ids).pluck(:name).join(", ")
      "Page on which action was taken #{is_clause} any of these: #{page_names}"
    end

  end
end
