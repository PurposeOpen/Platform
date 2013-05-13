class Api::ActivitiesController < Api::BaseController

  DEFAULT_ACTIVITY_FEED_REFRESH_FREQ = 30

  caches_action :show, :expires_in => (ENV['ACTIVITY_FEED_REFRESH_FREQ'].try(:to_i) || DEFAULT_ACTIVITY_FEED_REFRESH_FREQ).seconds, :cache_path => lambda { |_|
    request.fullpath
  }

  def show
    if ENV["DISABLE_#{@movement.slug.upcase}_ACTIVITY_FEED"] =~ /true/i
      render :json => [] and return
    end
    language = Language.find_by_iso_code(I18n.locale)
    page_id = params[:module_id].present? ? ContentModule.find(params[:module_id]).pages.first.id : nil
    feed = UserActivityEvent.load_feed(@movement, language, page_id, nil, with_comments_only?)
    response.headers['Expires'] = next_interval_timestamp_after_most_recent_timestamp(feed).httpdate
    eager_loaded_feed = UserActivityEvent.includes(:user).where(id: feed.map(&:id))
    render :json => eager_loaded_feed.to_json(:language => language)
  end

  private

  def with_comments_only?
    params[:type] == 'comments'
  end

  def next_interval_timestamp_after_most_recent_timestamp(feed)
    most_recent_time = feed.any? ? feed.first.created_at : Time.zone.now
    intervals, remainder = most_recent_time.sec.divmod(self.class.activity_feed_refresh_frequency)

    seconds_before_interval = intervals * self.class.activity_feed_refresh_frequency
    seconds_until_next_refresh = seconds_before_interval + self.class.activity_feed_refresh_frequency

    ( most_recent_time - most_recent_time.sec ) + seconds_until_next_refresh
  end

  def self.activity_feed_refresh_frequency
    @activity_feed_refresh_frequency ||= ENV['ACTIVITY_FEED_REFRESH_FREQ'].try(:to_i) || DEFAULT_ACTIVITY_FEED_REFRESH_FREQ
  end

  def self.activity_feed_refresh_frequency=(seconds)
    @activity_feed_refresh_frequency = seconds
  end

end
