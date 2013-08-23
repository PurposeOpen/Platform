class DummyMovementServer
  attr_reader :process

  RVM_GEMSET = "1.9.3-p194@dummy_movement"
  DUMMY_MOVEMENT_LOCATION = File.join(File.expand_path(Rails.root), "dummy_movement")
  PORT = 3001

  def start
    @process = ChildProcess.build("subcontract --rvm #{RVM_GEMSET} --chdir #{DUMMY_MOVEMENT_LOCATION} -- #{environment_variables} bundle exec rails s -p #{PORT}")
    @process.start
  end

  def stop
    @process.stop
  end

  def wait_till_server_is_up
    #TODO hit health dashboard until the status is OK
    sleep 2
  end

  private

  def dummy_movement_location
    @dummy_movement_location ||= File.join(File.expand_path(Rails.root), "dummy_movement")
  end

  def environment_variables
    env_hash = {
        "MOVEMENT_ID" => "dummy-movement",
        "MOVEMENT_NAME" => "DummyMovement",
        "MOVEMENT_BASIC_AUTH_PASSWORD" => "dummy-movement",
        "ACTION_CACHING_EXPIRATION" => "0",
        "PLATFORM_BASE_URI" => "#{Capybara.app_host}/api/",
        "BUNDLE_GEMFILE" => File.join(DUMMY_MOVEMENT_LOCATION, "Gemfile")
    }
    env_hash.each_with_object([]) {|(k,v), arr| arr << "env #{k}=#{v}"}.join(" ")
  end

end
