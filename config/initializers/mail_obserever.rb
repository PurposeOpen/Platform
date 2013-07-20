class MailObserver
  def self.delivered_email(message)
    Rails.logger.debug "LDEBUG: Actually Sent Message #{message}"
  end
end

ActionMailer::Base.register_observer(MailObserver)