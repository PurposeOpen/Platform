module Jobs
  class UpdateShareCache
    @queue = :update_share_cache
  
    def self.perform(page_id)
      Share.refresh_cache(page_id)
    end  
  end
end