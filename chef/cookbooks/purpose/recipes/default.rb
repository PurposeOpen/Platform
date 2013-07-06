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

#redis
package "redis-server"

# Update Ruby to 2.0.0
package "python-software-properties"
package "build-essential" 
package "openssl" 
package "libreadline6" 
package "libreadline6-dev" 
package "curl" 
package "git-core" 
package "zlib1g" 
package "zlib1g-dev" 
package "libssl-dev" 
package "libyaml-dev" 
package "libsqlite3-dev" 
package "sqlite3" 
package "libxml2-dev" 
package "libxslt-dev" 
package "autoconf" 
package "libc6-dev" 
package "libgdbm-dev" 
package "ncurses-dev" 
package "automake"
package "libtool" 
package "bison" 
package "subversion" 
package "pkg-config"
package "libffi-dev"

bash "install_ruby_2.0.0" do 
  code <<-EOH
  cd /tmp
  wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.gz
  tar -xvzf ruby-2.0.0-p0.tar.gz
  cd ruby-2.0.0-p0
  ./configure --prefix=/usr/local
  make
  make install
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
  RAILS_ENV=development bundle exec rake db:create
  RAILS_ENV=development bundle exec rake db:schema:load
  RAILS_ENV=development bundle exec rake db:migrate
  RAILS_ENV=development bundle exec rake db:seed_fu
  EOH
end

# Setup .env for foreman
template "/platform/.env" do
  source "env.erb"
  mode 0755
end

# Merge in env.local if it exists
ruby_block "install_env.local" do
  block do
    if File.exists?("/platform/env.local")
      content = File.read("/platform/env.local")
      open('/platform/.env', 'a') do |f|
        f.puts(content)
      end
    end
  end
end

# Go go go!
bash "go" do
  code <<-EOH
  cd /platform
  echo 'Now run this:'
  echo 'foreman start -f Procfile.dev'
  EOH
end
