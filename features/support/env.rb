require 'cucumber/rails'

ActionController::Base.allow_rescue = false

require 'capybara/poltergeist'
Capybara.register_driver :poltergeist do |app|
  options = { timeout: 120 }
  options[:inspector] = true if ENV['DEBUG']
  Capybara::Poltergeist::Driver.new(app, options)
end
Capybara.javascript_driver = :poltergeist
Capybara.default_driver = :poltergeist
Capybara.default_wait_time = 150
ActionController::Base.asset_host = Capybara.app_host


# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { :except => [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :truncation

Before do
  ENV['WHITELISTED_EMAIL_TEST_DOMAINS']='thoughtworks.com,purpose.com,purpose.org,allout.org'
end

Before('@without_transactional_fixtures') do |scenario|
  DatabaseCleaner.strategy = :truncation
end

After('@without_transactional_fixtures') do |scenario|
  DatabaseCleaner.clean
  DatabaseCleaner.strategy = :transaction
end

Before('@run_dummy_movement_server') do |scenario|
  @dummy_movement_server = DummyMovementServer.new
  @dummy_movement_server.start
  @dummy_movement_server.wait_till_server_is_up
end

After('@run_dummy_movement_server') do |scenario|
  @dummy_movement_server.stop
end

# Make sure this require is after you require cucumber/rails/world.
require 'email_spec' # add this line if you use spork
require 'email_spec/cucumber'

require 'sunspot_test/cucumber'
