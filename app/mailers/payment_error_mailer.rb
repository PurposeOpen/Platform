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

  def report_recurring_donation_error(donation, error)
    @donation = donation
    @error = error
    @member = donation.user
    movement = @member.movement
		recipient_list = error_emails_recipient_list(movement) # using same list as PAYPALERRORS
		return if recipient_list.nil? || recipient_list.empty?

		mail(:to => recipient_list, :from => PurposeMailer::DEFAULT_FROM, :subject => DEFAULT_SUBJECT % movement.name) do |format|
      format.text { render 'payment_error_mailer/report_recurring_donation_error' }
    end.with_settings(blast_email_settings(movement))
  end

  def recurring_donation_card_declined(donation)
    @donation = donation
    @member = donation.user
    @member_country = Country::COUNTRIES[@member.country_iso.to_s.upcase][:name] unless @member.country_iso.blank?
    @movement = @member.movement
    @contact_email = ENV["#{@movement.slug}_CONTACT_EMAIL".upcase]
    iso_code = @member.language.iso_code
    subject =  I18n.t('recurring_donation_card_declined_email_subject', :locale => iso_code.to_sym, :MOVEMENT_NAME => @movement.name )
    money = Money.new(donation.subscription_amount, donation.currency)
    @donation_amount = "#{money.symbol}#{money.to_s} #{donation.frequency.to_s}"
    @action_page_url = "#{@movement.url}/#{I18n.locale}/actions/#{donation.action_page.slug}"

    mail(:to => @member.email, :from => @contact_email, :subject => subject) do |format|
      format.text { render "payment_error_mailer/recurring_donation_card_declined.#{iso_code}" }
    end.with_settings(blast_email_settings(@movement))
  end

  private
	def error_emails_recipient_list(movement)
		(ENV["#{movement.slug.upcase}_PAYPALERROR_EMAIL_RECIPIENTS"] || '').split(',')
	end
end
