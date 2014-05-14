class Emailer < PurposeMailer
  include MailConfigulator

  def target_email(movement, targets, from, subject, body)
    @body_text = body
    mail(bcc: targets.gsub(",", " ").gsub(";", " ").split,
        from: from,
        subject: subject).with_settings(target_email_settings(movement))
  end
end
