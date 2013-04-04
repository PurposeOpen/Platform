  require "bundler/capistrano"

set :application, " "
set :repository,  "."
set :user, "vagrant"
set :rails_env, "vagrant"

set :scm, :none
set :deploy_via, :copy
set :bundle_flags,    "--deployment"

role :web, "localhost:2222"                          # Your HTTP server, Apache/etc
role :app, "localhost:2222"                          # This may be the same as your `Web` server
role :db,  "localhost:2222", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

 namespace :deploy do
   task :start do
     run "cd #{current_path} && bundle exec rails server thin -e #{rails_env} -d";
   end
   task :stop do 
     run "cd #{current_path} && (test -f tmp/pids/server.pid && kill `cat tmp/pids/server.pid`) || /bin/true";
   end
   task :restart, :roles => :app, :except => { :no_release => true } do
     deploy.stop
     deploy.start
   end
   
   task :fix_owner do
     run "sudo chown -R vagrant:vagrant /u/apps/"
   end

   task :precompile_assets do
     run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
   end
 end

 namespace :db do
   task :create do
     run "cd #{current_path} && bundle exec rake db:create RAILS_ENV=#{rails_env}"
   end
   task :seed do
     run "cd #{current_path} && bundle exec rake db:seed RAILS_ENV=#{rails_env}"
   end
   task :reset do
     run "cd #{current_path} && bundle exec rake db:reset RAILS_ENV=#{rails_env}"
   end
 end

 after 'deploy:setup', 'deploy:fix_owner'
 after 'deploy:update', 'deploy:precompile_assets'
