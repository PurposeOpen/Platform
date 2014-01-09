class PaymentSuccessMailer < PurposeMailer
  include MailConfigulator

  def confirm_purchase(donation, transaction)
    @donation = donation
    @member = donation.user
    @member_country = Country::COUNTRIES[@member.country_iso.to_s.upcase][:name] unless @member.country_iso.blank?
    @movement = @member.movement
    @transaction = transaction

    money = Money.new(transaction.amount_in_cents, transaction.currency)

    @contact_email = ENV["#{@movement.slug}_CONTACT_EMAIL".upcase]
    iso_code = @member.language.iso_code

    if donation.frequency == :one_off
      subject =  I18n.t('successful_payment_email_subject', :locale => iso_code.to_sym, :MOVEMENT_NAME => @movement.name )
      @transaction_amount = "#{money.symbol}#{money.to_s}"
    else
      subject =  I18n.t('successful_recurring_payment_email_subject', :locale => iso_code.to_sym, :MOVEMENT_NAME => @movement.name )
      @transaction_amount = "#{money.symbol}#{money.to_s} #{donation.frequency.to_s}"
    end

    mail(:to => @member.email, :from => @contact_email, :subject => subject) do |format|
      format.text { render "payment_success_mailer/confirm_purchase.#{iso_code}" }
    end.with_settings(blast_email_settings(@movement))
  end

  def confirm_recurring_donation_created(donation)
  end
end
