STDOUT.sync = true
STDERR.sync = true

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PurposePlatform::Application.initialize!
