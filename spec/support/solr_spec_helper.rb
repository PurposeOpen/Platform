$original_sunspot_session = Sunspot.session

module SolrSpecHelper
  def solr_up?
    uri = URI.parse("http://0.0.0.0:#{$sunspot.port}/solr/")
    begin
      Net::HTTP.get_response uri
      Rails.logger.info 'Solr started!!!'
      return true
    rescue Errno::ECONNREFUSED
      Rails.logger.info 'Solr yet to start...'
      return false
    end
  end

  def solr_setup
    unless $sunspot
      $sunspot = Sunspot::Rails::Server.new
      pid = fork do
        STDERR.reopen('/dev/null')
        STDOUT.reopen('/dev/null')
        $sunspot.run
      end
      # shut down the Solr server
      at_exit { Process.kill('TERM', pid) }
      # wait for solr to start
      raise 'SOLR COULD NOT BE STARTED..' unless 100.times.any?{sleep(1) && solr_up?}
    end

    Sunspot.session = $original_sunspot_session
  end
end

RSpec.configure do |config|
  config.include SolrSpecHelper
  config.before(:each) do
    if example.metadata[:solr]    # it "...", solr: true do ... to have real SOLR
      solr_setup
    else
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new($original_sunspot_session)
    end
  end

  config.after(:each) do
    if example.metadata[:solr]
      Sunspot.remove_all!
    else
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new($original_sunspot_session)
    end
  end
end
