module Jobs
  class UpdateMovementCache
    @queue = :update_movement_cache
  
    def self.perform(id)
      Movement.find(id).refresh_cache
    end  
  end
end