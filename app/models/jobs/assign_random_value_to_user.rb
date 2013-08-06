module Jobs
  class AssignRandomValueToUser
    @queue = :assign_random_value_to_user
  
    def self.perform(user_id)
      User.find(user_id).assign_random_value
    end  
  end
end