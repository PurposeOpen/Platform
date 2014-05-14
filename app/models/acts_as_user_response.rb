module ActsAsUserResponse
  def self.included(klass)
    klass.belongs_to :action_page, foreign_key: :page_id
    klass.belongs_to :content_module
    klass.belongs_to :user
    klass.belongs_to :email
    klass.validates_presence_of :action_page
    klass.validates_presence_of :content_module
    klass.validates_presence_of :user
  end
  
  private

  def create_activity_event
    UserActivityEvent.action_taken!(
        self.user,
        self.action_page,
        self.content_module,
        self,
        self.email,
        self.comment)
  end
end