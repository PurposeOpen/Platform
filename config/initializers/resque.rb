Dir["../../app/jobs/*.rb"].each { |file| require file }

Resque.redis = ENV['REDIS_URL'] || 'localhost'
Resque.redis.namespace = "resque:platform"
Resque.logger = Rails.logger


Resque.after_fork = Proc.new do
  ActiveRecord::Base.verify_active_connections!
  #Rails.logger.auto_flushing = true
end

require 'resque'
require 'resque-honeybadger'

require 'resque/failure/multiple'
require 'resque/failure/redis'

# If you don't already do `Honeybadger.configure` elsewhere.
Resque::Failure::Honeybadger.configure do |config|
  config.api_key = '1e93decd'
end

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Honeybadger]
Resque::Failure.backend = Resque::Failure::Multiple