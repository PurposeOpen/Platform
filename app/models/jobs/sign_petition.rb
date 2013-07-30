module Jobs
  class SignPetition
    @queue = :sign_petition
  
    def self.perform(user, action_info, page, petition_module_id)
      p = PetitionModule.find(petition_module_id)
      p.sign_petition(user, action_info, page, petition_module_id)
    end  
  end
end