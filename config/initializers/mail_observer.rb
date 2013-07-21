class MailObserver
  def self.delivered_email(message)
    Rails.logger.debug "LDEBUG: MailObserver Called"
  end
end

ActionMailer::Base.register_observer(MailObserver)