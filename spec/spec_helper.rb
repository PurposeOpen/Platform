require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

end

Spork.each_run do
  # This code will be run each time you run your specs.

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




require 'rubygems'
require 'spork'
require 'simplecov'

SimpleCov.start



# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "email_spec"
require 'models/content_module_shared_examples'

# override use securepay environment variable
ENV['USE_SECUREPAY'] = ''
ENV['WHITELISTED_EMAIL_TEST_DOMAINS']='generic.org,yourdomain.org,yourotherdomain.com'
ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_SUBJECT']= "Check out this campaign"
ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_BODY']   = "Why don't you check out this?"
ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_TWEET_TEXT']  ="Why don't you check out this?"
ENV['ACTION_SEQUENCE_DEFAULT_EMAIL_FACEBOOK_IMAGE']="images/blank_logo.png"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.backtrace_clean_patterns = []

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include FactoryGirl::Syntax::Methods
  config.before do
    ActionMailer::Base.deliveries = []
    I18n.locale = :en
  end
  config.include SunspotMatchers
  config.before(:each) { GeoData.stub(:find_by_zip_and_country).and_return(stub_model(GeoData, :lat => "45.0", :lng => "45.0")) }
end

def read_fixture(name)
  IO.readlines("#{::Rails.root}/spec/fixtures/#{name}")
end



# Custom matchers
[:same_array_regardless_of_order, :be_same_array_regardless_of_order].each do |matcher_name|
  RSpec::Matchers.define matcher_name do |expected|
    match do |actual|
      expected.sort == actual.sort
    end
  end
end


def without_transactional_fixtures(&block)

  before(:all) do
    @old_use_transactional_fixtures = self.use_transactional_fixtures
    self.class.use_transactional_fixtures = false
    DatabaseCleaner.strategy = :truncation
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
    self.class.use_transactional_fixtures = @old_use_transactional_fixtures
  end

  yield

end

def without_timestamping_of(*klasses, &block)
  begin
    klasses.each { |klass| klass.record_timestamps = false }
    yield
  ensure
    klasses.each { |klass| klass.record_timestamps = true }
  end
end

def create_simple_email(options={})
  user = options[:user] || FactoryGirl.create(:leo)
  email = options[:email] || FactoryGirl.create(:email, :language => user.language)
  email
end

RSpec::Matchers.define :be_valid do
  match do |model|
    model.valid?
  end

  failure_message_for_should do |model|
    "expected valid? to return true, got false:\n #{model.errors.full_messages.join("\n ")}"
  end

  failure_message_for_should_not do |model|
    "expected valid? to return false, got true"
  end

  description do
    "be valid"
  end
end

RSpec.configure do |config|
  config.around(:each, :caching => true) do |example|
    caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
    store, ActionController::Base.cache_store = ActionController::Base.cache_store, :memory_store
    silence_warnings { Object.const_set "RAILS_CACHE", ActionController::Base.cache_store }
    example.run

    silence_warnings { Object.const_set "RAILS_CACHE", store }
    ActionController::Base.cache_store = store
    ActionController::Base.perform_caching = caching
  end
end

def login_as(user)
  request.env['warden'] = double(Warden, :authenticate => user, :authenticate! => user)
end
