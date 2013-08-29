module Jobs
  class EmailOpenedEvent
    @queue = :event_tracking
  
    def self.perform(t)
      email_tracking_hash=EmailTrackingHash.decode(t)           
      if email_tracking_hash.valid?
        user =  email_tracking_hash.user
        email = email_tracking_hash.email
        UserActivityEvent.email_viewed!(user, email)
      else
        raise "Invalid tracking hash"
      end
    end  
  end
end