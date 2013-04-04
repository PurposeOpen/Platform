module ListCutter
  class CampaignRule < Rule
    fields :campaigns
    validates_presence_of :campaigns, :message => 'Please select one or more campaigns'
     
    def to_sql
      sanitize_sql <<-SQL, @movement.id, campaigns
        SELECT user_id FROM user_activity_events
        WHERE movement_id = ?
        AND campaign_id IN (?)
        GROUP BY user_id
      SQL
    end
    
    def active?
      !campaigns.blank?
    end

    def to_human_sql
      campaign_names = Campaign.where(:id => campaigns).map(&:name).join(", ")
      "Campaign #{is_clause} any of these: #{campaign_names}"
    end

  end
end
