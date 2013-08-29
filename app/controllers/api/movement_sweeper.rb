class Api::MovementSweeper < ActionController::Caching::Sweeper
  observe Movement 
 
  # If our sweeper detects that a Product was updated call this
  def after_update(movement)
    expire_cache_for(movement)
  end

private
  def expire_cache_for(movement)
#     Rails.logger.debug "clearing movement cache"
#     expire_action('views/es/api/movements/allout.json')
  end
  

end