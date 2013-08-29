#A fix because the injected Heroku plugin doesn't seem to log for rake tasks
ActiveRecord::Base.logger = Rails.logger
ActionMailer::Base.logger = Rails.logger