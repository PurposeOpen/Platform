require 'vcr'

VCR.configure do |config|
  config.configure_rspec_metadata!
  config.cassette_library_dir = 'spec/cassettes'
  config.default_cassette_options = { record: :new_episodes }
  config.hook_into :webmock
  config.ignore_localhost = true
end
WebMock.disable_net_connect!
