class PageSweeper < ActionController::Caching::Sweeper
  observe ActionPage

  def after_update(page)
    expire_cache_for(page)
  end

  private
  def expire_cache_for(page)
    expire_fragment(page.cache_key)
  end
end
