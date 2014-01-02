require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:setup" => :environment do
  require 'resque_scheduler'
  require 'resque/scheduler'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
