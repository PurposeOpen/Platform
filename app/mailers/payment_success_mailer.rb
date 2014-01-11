class PaymentSuccessMailer < PurposeMailer
  include MailConfigulator

  def confirm_purchase(donation, transaction)
    @donation = donation
    @member = donation.user
    @member_country = Country::COUNTRIES[@member.country_iso.to_s.upcase][:name] unless @member.country_iso.blank?
    @movement = @member.movement
    @transaction = transaction
    @contact_email = ENV["#{@movement.slug}_CONTACT_EMAIL".upcase]
    iso_code = @member.language.iso_code
    subject =  I18n.t('confirm_purchase_email_subject', :locale => iso_code.to_sym, :MOVEMENT_NAME => @movement.name )
    money = Money.new(transaction.amount_in_cents, transaction.currency)

    if donation.frequency.to_sym == :one_off
      @transaction_amount = "#{money.symbol}#{money.to_s}"
    else
      @transaction_amount = "#{money.symbol}#{money.to_s} #{donation.frequency.to_s}"
    end

    mail(:to => @member.email, :from => @contact_email, :subject => subject) do |format|
      format.text { render "payment_success_mailer/confirm_purchase.#{iso_code}" }
    end.with_settings(blast_email_settings(@movement))
  end

  def confirm_recurring_purchase(donation, transaction)
    @donation = donation
    @member = donation.user
    @member_country = Country::COUNTRIES[@member.country_iso.to_s.upcase][:name] unless @member.country_iso.blank?
    @movement = @member.movement
    @transaction = transaction
    @contact_email = ENV["#{@movement.slug}_CONTACT_EMAIL".upcase]
    iso_code = @member.language.iso_code
    subject =  I18n.t('confirm_recurring_purchase_email_subject', :locale => iso_code.to_sym, :FREQUENCY => donation.frequency.to_s.downcase, :MOVEMENT_NAME => @movement.name )
    money = Money.new(transaction.amount_in_cents, transaction.currency)
    @transaction_amount = "#{money.symbol}#{money.to_s} #{donation.frequency.to_s}"

    mail(:to => @member.email, :from => @contact_email, :subject => subject) do |format|
      format.text { render "payment_success_mailer/confirm_purchase.#{iso_code}" }
    end.with_settings(blast_email_settings(@movement))
  end

  def confirm_recurring_donation_created(donation)
  end
end
