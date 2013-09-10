# Be sure to restart your server when you modify this file.


#PurposePlatform::Application.config.session_store :cookie_store, :key => '_purpose_platform_session'

PurposePlatform::Application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 8.hours

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Tijuana::Application.config.session_store :active_record_store
