# Install Purpose platform FOR DEVELOPMENT on a Heroku-esque platform
#
# NOTE THIS SHOULD NOT BE USED FOR PRODUCTION
# In particular, no security measures are put in place

# Basics
package "build-essential"
package "curl"

# Install MySQL
package "mysql-server"
package "mysql-client"
package "libmysqlclient-dev"

# Git some!
package "git-core"

# Dependencies for Nokogiri
package "libxml2-dev"
package "libxslt-dev"

# ImageMagick
package "libmagick9-dev"


# Update Ruby to 1.9.3
package "python-software-properties"
bash "update_ruby" do
  code <<-EOH
  apt-add-repository ppa:brightbox/ruby-ng
  apt-get update
  EOH
end
package "ruby"
package "rubygems"
package "ruby-switch"
package "ruby1.9.3"
bash "switch_default_ruby" do
  code <<-EOH
  ruby-switch --set ruby1.9.1
  EOH
end


# Create directory for platform code
# Currently redundant. Keep around for later use.
directory "/var/www/platform" do
  action :create
  owner "vagrant"
  mode "0755"
  recursive true
end

# Setup platform
#
# - Need to update gem to parse factory girl gem spec. This breaks
#   compatibility with Heroku which has gem fixed at an old version
#   but this gem is only needed for testing so it isn't a big deal.
bash "setup_platform" do
  code <<-EOH
  cd /platform
  gem update --system
  gem install bundler
  bundle install
  EOH
end

# Setup MySQL
#
# - Symlink MySQL socket to the location expected by Platform
#
# - Set permissions to allow vagrant user to connect
bash "setup_mysql" do
  code <<-EOH
  ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock
  mysql -e "GRANT ALL ON *.* to vagrant@'%'; FLUSH PRIVILEGES;"
  EOH
end

# Configure platform
#
# - Create the stuff we need to create. In particular seed the database with a dummy admin
bash "configure_platform" do
  code <<-EOH
  cd /platform
  RAILS_ENV=development rake db:create
  RAILS_ENV=development rake db:schema:load
  RAILS_ENV=development rake db:migrate
  RAILS_ENV=development rake db:seed_fu
  EOH
end

# Setup .env for foreman
template "/platform/.env" do
  source "env.erb"
  mode 0755
end

# Go go go!
bash "go" do
  code <<-EOH
  cd /platform
  echo 'Now run this:'
  echo 'foreman start -f Procfile.dev'
  EOH
end
