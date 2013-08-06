module Jobs
  class UpdatePageActionTakenCounter
    @queue = :update_page_action_taken_counter
  
    def self.perform(page_id)
      Page.find(page_id).update_page_action_taken_counter
    end  
  end
end