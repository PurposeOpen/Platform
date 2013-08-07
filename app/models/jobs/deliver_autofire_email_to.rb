module Jobs
  class DeliverAutofireEmailTo
    @queue = :send_join_email
  
    def self.perform(action_page_id, user_id, user_response)
      ActionPage.find(action_page_id).async_deliver_autofire_email_to(user_id, user_response)
    end  
  end
end