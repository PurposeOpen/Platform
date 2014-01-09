class PaymentSuccessMailer < PurposeMailer
  include MailConfigulator

  def confirm_recurring_payment_purchase(donation, spreedly_transaction)
    @member = donation.user

    recipient_list = @member.email
    return if recipient_list.blank?

    iso_code = @member.language.iso_code
    subject =  I18n.t('successful_payment_email_subject', :locale => iso_code.to_sym )

    @contact_email = ENV["#{@member.movement.slug}_CONTACT_EMAIL".upcase]
    mail(
      :to => recipient_list,
      :from => @contact_email,
      :subject => subject) do |format|
        format.text { render "payment_success_mailer/confirm_recurring_payment_purchase.#{iso_code}" }
      end.with_settings(blast_email_settings(donation_error.movement))
  end

  def confirm_recurring_donation_created(donation)
  end
end
