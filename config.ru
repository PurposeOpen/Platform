# This file is used by Rack-based servers to start the application.

require 'rack/handler'
Rack::Handler::WEBrick = Rack::Handler.get(:puma)

require ::File.expand_path('../config/environment',  __FILE__)

run PurposePlatform::Application
