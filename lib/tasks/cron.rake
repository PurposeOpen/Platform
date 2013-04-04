namespace :cron do

  desc 'Calculate statistics for email blasts'
  task :update_email_stats => :environment do
    UniqueActivityByEmail.update!
  end

  desc 'Clear email stats table'
  task :reset_email_stats => :environment do
    UniqueActivityByEmail.reset!
  end

  desc 'Update member count'
  task :update_member_count => :environment do
    MemberCountCalculator.update_all_counts! 
  end

  task :clean_list_intermediate_results => :environment do
    cleanup_query = "delete from list_intermediate_results where id not in (select saved_intermediate_result_id from lists where saved_intermediate_result_id is not NULL) and ready is true"
    ActiveRecord::Base.connection.execute(cleanup_query)
  end
end
