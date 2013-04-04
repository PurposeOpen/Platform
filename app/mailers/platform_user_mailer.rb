class PlatformUserMailer < PurposeMailer

  def subscription_confirmation_email(platform_user)
    @body_text = {}
    processed_body = pre_process(PlatformUserEmailTemplates::SUBSCRIPTION_CONFIRMATION, platform_user)
    @body_text[:html] = processed_body
    @body_text[:text] = Nokogiri::HTML::DocumentFragment.parse(processed_body).text
    mail_using_generic_template(:to => platform_user.email, :subject => "Welcome to Your Name Movement Management Platform!")
  end

  def pre_process(body, platform_user)
    replace_tokens(body,
      "NAME" => platform_user.full_name,
      "PASSWORD_URL" => new_platform_user_password_url
    )
  end
  private :pre_process

end
