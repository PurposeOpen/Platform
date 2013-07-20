DOWNLOAD_DIR = '/vagrant/downloaded'
MYSQL_DOWNLOAD_URL = 'http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.12-debian6.0-x86_64.deb'
MYSQL_DOWNLOAD_FILE = "#{DOWNLOAD_DIR}/mysql-5.6.10-debian6.0-x86_64.deb"

package "mysql-server"
package "mysql-client"
package "libaio1"

directory DOWNLOAD_DIR

remote_file MYSQL_DOWNLOAD_FILE do
  source MYSQL_DOWNLOAD_URL
  mode 0644
  action :create_if_missing
  checksum "b8f70c35e50cf49a4c8ed01d731b7d64"
end

template '/etc/my.cnf' do
  source 'my.cnf.erb'
  mode "0644"
end

template '/etc/profile.d/mysql56.sh' do
  source 'mysql56.sh.erb'
  mode "0644"
end

# Setup MySQL
#
# - Symlink MySQL socket to the location expected by Platform
#
# - Set permissions to allow vagrant user to connect
#bash "setup_mysql" do
#  code <<-EOH
#  ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock
#  mysql -e "GRANT ALL ON *.* to vagrant@'%'; FLUSH PRIVILEGES;"
#  EOH
#end

script 'install MySQL 5.6' do
  interpreter 'bash'
  user 'root'
  code <<-SCRIPT
    dpkg -i #{MYSQL_DOWNLOAD_FILE}
    cp /opt/mysql/server-5.6/support-files/mysql.server /etc/init.d/mysql.server
    update-rc.d mysql.server defaults
    chown -R mysql /opt/mysql/server-5.6/
    chgrp -R mysql /opt/mysql/server-5.6/
    service mysql stop
    apt-get remove mysql-server mysql-server-5.5 mysql-server-core-5.5
    rm /etc/mysql/my.cnf
    /opt/mysql/server-5.6/scripts/mysql_install_db --user=mysql --datadir=/var/lib/mysql
    rm /opt/mysql/server-5.6/my.cnf
    chmod 0744 /var/lib/mysql
    service mysql.server start
    mysql_upgrade
  SCRIPT
end