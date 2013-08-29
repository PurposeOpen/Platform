# config/initializers/delayed_job_config.rb
Delayed::Worker.backend = :active_record
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 3
Delayed::Worker.max_attempts = 2
Delayed::Worker.max_run_time = 20.minutes
Delayed::Worker.delay_jobs = true
Delayed::Worker.default_queue_name = ENV['DEFAULT_QUEUE'] || "default"
Delayed::Worker.logger = Rails.logger

module QueueConfigs
  LIST_CUTTER_BLASTER_QUEUE = ENV['LIST_CUTTER_BLASTER_QUEUE'] || "list_cutter_blaster"
end