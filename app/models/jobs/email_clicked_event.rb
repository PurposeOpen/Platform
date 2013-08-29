module Jobs
  class EmailClickedEvent
    @queue = :event_tracking
  
    def self.perform(movement_id,page_type,page_id,t)
      email_tracking_hash = EmailTrackingHash.decode(t)
      if email_tracking_hash.valid?
        movement = Movement.find(movement_id)
        page = (page_type == "Homepage" ? movement.homepage : movement.find_page(page_id))
        user = email_tracking_hash.user
        email = email_tracking_hash.email
        page.register_click_from email, user
      else
        raise "Invalid tracking hash"
      end             
    end
  
  end
end
