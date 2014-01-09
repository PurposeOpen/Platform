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
ENV['JOIN_EMAIL_TO']='test@purpose.com'
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
    Resque.inline = true 
  end
  config.include SunspotMatchers
  config.include BackgroundJobs
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
  config.before(:each) do
      full_example_description = "**** TEST Starting: #{self.class.description} #{@method_name} #{@example.description}"
      Rails.logger.info("\n\n#{full_example_description}\n#{'-' * (full_example_description.length)}")      
  end
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

def successful_payment_method_response_xml
  <<-XML
      <payment_method>
        <token>CATQHnDh14HmaCrvktwNdngixMm</token>
        <created_at type="datetime">2013-12-21T12:51:47Z</created_at>
        <updated_at type="datetime">2013-12-21T12:51:47Z</updated_at>
        <email>frederick@example.com</email>
        <data>
          <frequency>weekly</frequency>
          <currency>usd</currency>
          <amount>2000</amount>
        </data>
        <storage_state>cached</storage_state>
        <last_four_digits>1111</last_four_digits>
        <card_type>visa</card_type>
        <first_name>Bob</first_name>
        <last_name>Smith</last_name>
        <month type="integer">1</month>
        <year type="integer">2020</year>
        <address1>345 Main Street</address1>
        <address2>Apartment #7</address2>
        <city>Wanaque</city>
        <state>NJ</state>
        <zip>07465</zip>
        <country>United States</country>
        <phone_number>201-332-2122</phone_number>
        <full_name>Bob Smith</full_name>
        <payment_method_type>credit_card</payment_method_type>
        <errors>
        </errors>
        <verification_value>XXX</verification_value>
        <number>XXXX-XXXX-XXXX-1111</number>
      </payment_method>
  XML
end

def failed_payment_method_response_xml
  <<-XML
      <errors>
        <error key="errors.payment_method_not_found">Unable to find the specified payment method.</error>
      </errors>
  XML
end

def successful_purchase_response_xml
  <<-XML
      <transaction>
        <amount type="integer">100</amount>
        <on_test_gateway type="boolean">true</on_test_gateway>
        <created_at type="datetime">2013-12-12T22:47:05Z</created_at>
        <updated_at type="datetime">2013-12-12T22:47:05Z</updated_at>
        <currency_code>USD</currency_code>
        <succeeded type="boolean">true</succeeded>
        <state>succeeded</state>
        <token>CtK2hq1rB9yvs0qYvQz4ZVUwdKh</token>
        <transaction_type>Purchase</transaction_type>
        <order_id nil="true"/>
        <ip nil="true"/>
        <description nil="true"/>
        <email nil="true"/>
        <merchant_name_descriptor nil="true"/>
        <merchant_location_descriptor nil="true"/>
        <gateway_specific_fields nil="true"/>
        <gateway_specific_response_fields nil="true"/>
        <gateway_transaction_id>59</gateway_transaction_id>
        <message key="messages.transaction_succeeded">Succeeded!</message>
        <gateway_token>7V55R2Y8oZvY1u797RRwMDakUzK</gateway_token>
        <response>
          <success type="boolean">true</success>
          <message>Successful purchase</message>
          <avs_code nil="true"/>
          <avs_message nil="true"/>
          <cvv_code nil="true"/>
          <cvv_message nil="true"/>
          <pending type="boolean">false</pending>
          <error_code></error_code>
          <error_detail nil="true"/>
          <cancelled type="boolean">false</cancelled>
          <created_at type="datetime">2013-12-12T22:47:05Z</created_at>
          <updated_at type="datetime">2013-12-12T22:47:05Z</updated_at>
        </response>
        <payment_method>
          <token>SvVVGEsjBXRDhhPJ7pMHCnbSQuT</token>
          <created_at type="datetime">2013-11-06T18:28:14Z</created_at>
          <updated_at type="datetime">2013-12-12T22:47:05Z</updated_at>
          <email nil="true"/>
          <data>
            <frequency>weekly</frequency>
            <currency>usd</currency>
            <amount>2000</amount>
          </data>
          <storage_state>retained</storage_state>
          <last_four_digits>1111</last_four_digits>
          <card_type>visa</card_type>
          <first_name>Gia</first_name>
          <last_name>Hammes</last_name>
          <month type="integer">4</month>
          <year type="integer">2020</year>
          <address1 nil="true"/>
          <address2 nil="true"/>
          <city nil="true"/>
          <state nil="true"/>
          <zip nil="true"/>
          <country nil="true"/>
          <phone_number nil="true"/>
          <full_name>Gia Hammes</full_name>
          <payment_method_type>credit_card</payment_method_type>
          <errors>
          </errors>
          <verification_value></verification_value>
          <number>XXXX-XXXX-XXXX-1111</number>
        </payment_method>
        <api_urls>
        </api_urls>
      </transaction>
  XML
end

def failed_purchase_response_xml
  <<-XML
      <transaction>
        <amount type="integer">100</amount>
        <on_test_gateway type="boolean">false</on_test_gateway>
        <created_at type="datetime">2013-12-21T12:51:49Z</created_at>
        <updated_at type="datetime">2013-12-21T12:51:49Z</updated_at>
        <currency_code>USD</currency_code>
        <succeeded type="boolean">false</succeeded>
        <state>failed</state>
        <token>Hj5BPvWQJ0EPH6egV8hIztWMCOY</token>
        <transaction_type>Purchase</transaction_type>
        <order_id nil="true"/>
        <ip nil="true"/>
        <description nil="true"/>
        <email nil="true"/>
        <merchant_name_descriptor nil="true"/>
        <merchant_location_descriptor nil="true"/>
        <gateway_specific_fields nil="true"/>
        <gateway_specific_response_fields nil="true"/>
        <gateway_transaction_id nil="true"/>
        <message key="messages.payment_method_invalid">The payment method is invalid.</message>
        <gateway_token>GnWTB6GhqChi7VHGQSCgKDUZvNF</gateway_token>
        <payment_method>
          <token>Klrks0iaZLWbKQnDwiB4nBZYob5</token>
          <created_at type="datetime">2013-12-21T12:51:48Z</created_at>
          <updated_at type="datetime">2013-12-21T12:51:48Z</updated_at>
          <email nil="true"/>
          <data>
            <frequency>weekly</frequency>
            <currency>usd</currency>
            <amount>2000</amount>
          </data>
          <storage_state>cached</storage_state>
          <last_four_digits></last_four_digits>
          <card_type nil="true"/>
          <first_name></first_name>
          <last_name></last_name>
          <month nil="true"/>
          <year nil="true"/>
          <address1 nil="true"/>
          <address2 nil="true"/>
          <city nil="true"/>
          <state nil="true"/>
          <zip nil="true"/>
          <country nil="true"/>
          <phone_number nil="true"/>
          <full_name></full_name>
          <payment_method_type>credit_card</payment_method_type>
          <errors>
            <error attribute="first_name" key="errors.blank">First name can't be blank</error>
            <error attribute="last_name" key="errors.blank">Last name can't be blank</error>
            <error attribute="month" key="errors.invalid">Month is invalid</error>
            <error attribute="year" key="errors.expired">Year is expired</error>
            <error attribute="year" key="errors.invalid">Year is invalid</error>
            <error attribute="number" key="errors.blank">Number can't be blank</error>
          </errors>
          <verification_value></verification_value>
          <number></number>
        </payment_method>
        <api_urls>
        </api_urls>
      </transaction>
  XML
end

def successful_purchase_and_hash_response
  { :token=>"CtK2hq1rB9yvs0qYvQz4ZVUwdKh",
    :created_at=>'2013-12-12 22:47:05 UTC',
    :updated_at=>'2013-12-12 22:47:05 UTC',
    :state=>"succeeded",
    :message=>"Succeeded!",
    :succeeded=>true,
    :order_id=>"",
    :ip=>"",
    :description=>"",
    :gateway_token=>"7V55R2Y8oZvY1u797RRwMDakUzK",
    :merchant_name_descriptor=>"",
    :merchant_location_descriptor=>"",
    :on_test_gateway=>true,
    :currency_code=>"USD",
    :amount=>100,
    :payment_method=>{
      :token=>"SvVVGEsjBXRDhhPJ7pMHCnbSQuT",
      :created_at=>"2013-11-06 18:28:14 UTC",
      :updated_at=>"2013-12-12 22:47:05 UTC",
      :email=>"",
      :storage_state=>"retained",
      :data=>{:classification=>"501-c-3"},
      :first_name=>"Gia",
      :last_name=>"Hammes",
      :full_name=>"Gia Hammes",
      :month=>"4", :year=>"2020",
      :number=>"XXXX-XXXX-XXXX-1111",
      :last_four_digits=>"1111",
      :card_type=>"visa",
      :verification_value=>"",
      :address1=>"",
      :address2=>"",
      :city=>"",
      :state=>"",
      :zip=>"",
      :country=>"",
      :phone_number=>""}
  }
end

def failed_purchase_and_hash_response
  { :code=>422,
    :errors=>{
    :attribute=>"first_name",
    :key=>"errors.blank",
    :message=>"First name can't be blank" 
  },
  :payment_method=>{
    :token=>"CATQHnDh14HmaCrvktwNdngixMm",
    :created_at=>"2013-12-21 12:51:47 UTC",
    :updated_at=>"2013-12-21 12:51:47 UTC",
    :email=>"frederick@example.com",
    :storage_state=>"cached",
    :data=>{
      :classification=>"501-c-3",
      :currency=>"USD"
    },
    :first_name=>"Bob",
    :last_name=>"Smith",
    :full_name=>"Bob Smith",
    :month=>"1",
    :year=>"2020",
    :number=>"XXXX-XXXX-XXXX-1111",
    :last_four_digits=>"1111",
    :card_type=>"visa",
    :verification_value=>"XXX",
    :address1=>"345 Main Street",
    :address2=>"Apartment #7",
    :city=>"Wanaque",
    :state=>"NJ",
    :zip=>"07465",
    :country=>"United States",
    :phone_number=>"201-332-2122"
  }
  }
end

def valid_donation_action_info
  { :confirmed => false,
    :frequency => :monthly,
    :currency => 'USD',
    :amount => 100,
    :payment_method => 'credit_card',
    :email => @email,
    :transaction_id => 'CtK2hq1rB9yvs0qYvQz4ZVUwdKh',
    :subscription_amount => 100,
    :payment_method_token =>'SvVVGEsjBXRDhhPJ7pMHCnbSQuT',
    :card_last_four_digits => '1111',
    :card_exp_month => '4',
    :card_exp_year => '2020' }
end
