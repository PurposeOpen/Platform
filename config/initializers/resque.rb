Dir["../../app/jobs/*.rb"].each { |file| require file }

Resque.redis = ENV['REDIS_URL'] || 'localhost'
Resque.redis.namespace = "resque:platform"
Resque.logger = Rails.logger


Resque.after_fork = Proc.new do
  ActiveRecord::Base.verify_active_connections!  
  #Rails.logger.auto_flushing = true
end