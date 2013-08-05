class PurposeMailer < ActionMailer::Base
  include InlineTokenReplacement

  DEFAULT_FROM = AppConstants.no_reply_address

  default :content_type => "text/html"

  def mail_using_generic_template(options, &block)
    mail_options = {
      :from => options[:from].present? ? options[:from] : DEFAULT_FROM,
      :to => options[:to],
      :subject => options[:subject]
    }

    if block_given?
      mail(mail_options, &block)
    else
      mail(mail_options) do |format|
        format.text { render 'generic_text_email' }
        format.html { render 'generic_html_email' }
      end
    end
  end
end