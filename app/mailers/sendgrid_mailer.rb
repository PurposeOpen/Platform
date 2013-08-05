class SendgridMailer < ActionMailer::Base

  def user_email(email, user, tokens = {})
    return unless user.can_subscribe?

    @body_text = pre_process_body(email.body, user, tokens)
    @footer = email.footer

    options = {
      :to => AppConstants.no_reply_address,
      :subject => email.subject,
      :recipients => [user.email]
    }
    options.merge!({:from => email.from}) if email.respond_to?(:from)

    prepared_mail=prepare(email, options)
    prepared_mail.deliver
    prepared_mail
  end

  def blast_email(email, options)
    @body_text = { :html => email.html_body, :text => email.plain_text_body }
    @footer = email.footer.present? ? { :html => email.footer.html_with_beacon, :text => email.footer.text } : {}
    options[:recipients] = clean_recipient_list(options[:recipients])

    prepare(email, options)
  end


  def prepare(email, options)
    headers['X-SMTPAPI'] = prepare_sendgrid_headers(email, options)
    headers['List-Unsubscribe' ] = "<mailto:#{email.from}>"
    subject = get_subject(email, options)

    mail(:to => AppConstants.no_reply_address, :from => email.from, :reply_to => (email.reply_to || email.from), :subject => subject) do |format|
      format.text { render 'sendgrid_mailer/text_email' }
      format.html { render 'sendgrid_mailer/html_email' }
    end.with_settings(blast_email_settings(email.movement))
  end

  def pre_process_body(body, user, tokens = {})
    raise "Error sending email: body cannot be empty" if body.blank?
    processed_body = replace_tokens(body, {
      "NAME" => user.greeting,
      "FULLNAME" => user.full_name,
      "EMAIL" => user.email,
      "POSTCODE" => user.postcode,
      "COUNTRY" => country_name(user.country_iso, user.language.iso_code.to_s),
      "PASSWORD_URL" => new_user_password_url,
      "MOVEMENT_NAME" => user.movement.name
    }.merge(tokens || {}))

    {
      :html => processed_body,
      :text => convert_html_to_plain(processed_body)
    }
  end


protected  

  #TODO: #include SendGrid
  include SendgridTokenReplacement
  include InlineTokenReplacement
  include MailConfigulator
  include CountryHelper
  include EmailBodyConverter






  def prepare_sendgrid_headers(email_to_send, options)
    category = email_to_send.respond_to?(:blast) ? ["push_#{email_to_send.blast.push.id}", "blast_#{email_to_send.blast.id}"] : []
    category += ["#{email_to_send.class.name.downcase}_#{email_to_send.id}", email_to_send.movement.friendly_id, Rails.env, email_to_send.language.iso_code]

    email_headers = {
      'to' => options[:recipients],
      'category' => category,
      'sub' => get_substitutions_list(email_to_send, options),
      'unique_args' => { 'email_id' => email_to_send.id }
    }

    raise_error_if_sizes_dont_match(options[:recipients].size, email_headers['sub'][email_headers['sub'].keys.first].size)
    email_headers.to_json
  end

  def raise_error_if_sizes_dont_match(no_recipients, no_tokens)
    if no_recipients != no_tokens
      msg = "Error sending blast: The number of recipients (#{no_recipients}) doesn't match the number of replacement tokens (#{no_tokens})."
      Rails.logger.error msg
      raise RuntimeError.new msg
    end
  end

  def get_subject(email_to_send, options)
    options[:test] ? "[TEST]#{email_to_send.subject}" : email_to_send.subject
  end

  def clean_recipient_list(recipients=[])
    if AppConstants.enable_unfiltered_blasting
      recipients
    else
      w_emails_test_domains = ENV['WHITELISTED_EMAIL_TEST_DOMAINS'].blank? ? [] : ENV['WHITELISTED_EMAIL_TEST_DOMAINS'].split(",")
      recipients.select {|email| w_emails_test_domains.any? {|domain| email.ends_with?(domain) } }
    end
  end

  


end
