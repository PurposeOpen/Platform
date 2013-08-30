PurposePlatform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils                        = true

                                                           # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  
  config.action_controller.perform_caching = true
  #onfig.cache_store = :redis_store

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.default_url_options = { :host => 'localhost' }

  Paperclip.options[:command_path] = "/usr/local/bin/"

  
  #config.autoload_paths += %W(#{Rails.root}/app/jobs)

  config.action_mailer.raise_delivery_errors = true

  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = true
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  #   # Bullet.growl = true
  #   # Bullet.xmpp = { :account => 'bullets_account@jabber.org',
  #   #                 :password => 'bullets_password_for_jabber',
  #   #                 :receiver => 'your_account@jabber.org',
  #   #                 :show_online_status => true }
  #   Bullet.rails_logger = true
  #   # Bullet.airbrake = true
  #   Bullet.disable_browser_cache = true
  # end
  config.middleware.use(Oink::Middleware, :logger => Rails.logger)
end
