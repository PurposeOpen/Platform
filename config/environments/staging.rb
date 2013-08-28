PurposePlatform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_controller.perform_caching = false if ENV['DISABLE_CACHE']=='false'

  config.action_controller.allow_forgery_protection    = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug
  #config.logger = Logger.new(STDOUT)
  
  config.log_level = ENV['LOG_LEVEL'].blank? ? :info : ENV['LOG_LEVEL'].to_sym

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  #redis_url = ENV['REDIS_URL']
  #config.cache_store = :redis_store, "#{redis_url}" #, { expires_in: 90.minutes }
  if ENV['MEMCACHE_SERVERS']
    memcache_servers = ENV['MEMCACHE_SERVERS'].split(",")
  else
    memcache_servers = "127.0.0.1:11211"
  end
  config.cache_store = :dalli_store, memcache_servers, { :namespace => "allout_platform_staging", :expires_in => 10.days, :compress => true, :username => ENV['COUCHBASE_BUCKETNAME'], :password => ENV['MEMCACHE_PASSWORD'] }
  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.raise_delivery_errors = true

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  
  config.threadsafe! unless defined?($rails_rake_task) && $rails_rake_task

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.action_mailer.default_url_options = { :host => 'allout-platform-preview.herokuapp.com' }
  config.action_controller.default_url_options = { :host => 'allout-platform-preview.herokuapp.com' }

  # config.action_controller.asset_host = "https://#{S3[:bucket]}.s3.amazonaws.com"

  config.assets.precompile += %w( admin.css admin.js health_dashboard.css tinymce/plugins/purposeImageManagerPlugin/editor_plugin.js tinymce/plugins/purposeImageManagerPlugin/js/dialog.js)
end
