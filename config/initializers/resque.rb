Dir["../../app/jobs/*.rb"].each { |file| require file }

Resque.redis = ENV['REDIS_URL'] || 'localhost'
Resque.redis.namespace = "resque:platform"
Resque.logger = Rails.logger


Resque.after_fork = Proc.new do
  #Rails.logger.auto_flushing = true
end