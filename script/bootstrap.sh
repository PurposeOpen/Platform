#!/usr/bin/env ruby

puts "--> Checking for mysql installation.\n"
check_for_mysql = `which mysql`
raise "You don't have mysql installed. Please install it." if check_for_mysql == ""

puts "--> Checking mysql credentials.\n"
mysql_login_response = `mysqldump -u root platform 2>&1`
if mysql_login_response =~ /Got error: 1044/
  raise "Cannot login with default root user. Please configure your mysql credentials in config/database.yml"
elsif mysql_login_response =~ /Got error: 2002/
  raise "mysql is not running. Please start it."
end

check_for_image_magick=`which identify`
raise "You don't have ImageMagick installed. Please install it." if check_for_image_magick == ""

puts "--> Installing gems"
bundle_install_response = `bundle install`


puts "--> Creating databases"
`rake db:create`

puts "--> Loading database schema"
`rake db:schema:load`

puts "--> Seeding development database"
`rake db:seed_fu`

puts "--> Ensuring that solr is running..."
solr_process_response = `ps -ef | grep solr | grep -v grep`
if solr_process_response == ""
  `rake sunspot:solr:start`
  `rake sunspot:reindex`
end

puts "--> Done!"
puts "--> Please run rake test:pre:checkin to make sure you have a working environment."

puts "--> Once you have a running server, you can login by going to /admin and using the following credentials:"
puts "--> username: admin@admin.com"

puts "--> password: password"
