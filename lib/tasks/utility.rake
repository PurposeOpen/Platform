namespace :utility do 
  task :print_debug => :environment do 
    puts "Rails.logger: "
    puts Rails.logger.inspect
  
    puts "ActiveRecord::Base.logger"
    puts ActiveRecord::Base.logger.inspect
    
    puts "STDERR.sync #{STDERR.sync}"
    puts "STDOUT.sync #{STDOUT.sync}"
  
  end
end