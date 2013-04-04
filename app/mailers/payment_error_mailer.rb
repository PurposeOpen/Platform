class PaymentErrorMailer < ActionMailer::Base
	#TODO: include SendGrid
	include MailConfigulator

	DEFAULT_SUBJECT = "[%s] - Payment Transaction Error"

	def report_error(donation_error)		
		recipient_list = error_emails_recipient_list(donation_error.movement)
		if recipient_list.nil? || recipient_list.empty?
			return
		end

		@donation_error = donation_error
		mail(:to => recipient_list, :from => PurposeMailer::DEFAULT_FROM, :subject => DEFAULT_SUBJECT % donation_error.movement.name) do |format|
      format.text { render 'payment_error_mailer/report_error' }
    end.with_settings(blast_email_settings(donation_error.movement))
	end

  def report_error_to_member(donation_error)
    recipient_list = donation_error.member_email
    if recipient_list.nil? || recipient_list.empty?
      return
    end

    subject =  I18n.t('failed_payment_email_subject', :locale => donation_error.member_language_iso.to_sym )

    subject = subject.gsub("{MOVEMENT_NAME}", donation_error.movement.name)

    @contact_email = ENV["#{donation_error.movement.slug}_CONTACT_EMAIL".upcase]
    @donation_error = donation_error
    mail(:to => recipient_list, :from => @contact_email, :subject => subject) do |format|
      format.text { render "payment_error_mailer/report_error_to_member.#{donation_error.member_language_iso}" }
    end.with_settings(blast_email_settings(donation_error.movement))
  end


  private
	def error_emails_recipient_list(movement)
		(ENV["#{movement.slug.upcase}_PAYPALERROR_EMAIL_RECIPIENTS"] || '').split(',')
	end
end