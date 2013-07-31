module Jobs
  class SignPetition
    @queue = :sign_petition
  
    def self.perform(user_id, action_info, page_id, petition_module_id)
      p = PetitionModule.find(petition_module_id)
      p.sign_petition(user_id, action_info, page_id, petition_module_id)
    end  
  end
end