class ActivitiesReport < ReportTable
  def self.columns
    ['Created','Action','Page','Action Type','User Language','Email','First Name','Last Name','Name Safe','Country','Postcode','Mobile','Comment','Comment Safe']
  end

  def initialize(user_activity_events)
    @user_activity_events = user_activity_events
  end

  def rows
    @user_activity_events.collect &:to_row
  end
end
