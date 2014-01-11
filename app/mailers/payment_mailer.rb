class PaymentMailer < PurposeMailer
  include MailConfigulator

  def expiring_credit_card(donation)
    @donation = donation
    @member = donation.user
    @member_country = Country::COUNTRIES[@member.country_iso.to_s.upcase][:name] unless @member.country_iso.blank?
    @movement = @member.movement
    @contact_email = ENV["#{@movement.slug}_CONTACT_EMAIL".upcase]
    iso_code = @member.language.iso_code
    subject =  I18n.t('expiring_credit_card_email_subject', :locale => iso_code.to_sym, :MOVEMENT_NAME => @movement.name )
    money = Money.new(donation.subscription_amount, donation.currency)
    @donation_amount = "#{money.symbol}#{money.to_s} #{donation.frequency.to_s}"

    mail(:to => @member.email, :from => @contact_email, :subject => subject) do |format|
      format.text { render "payment_mailer/expiring_credit_card.#{iso_code}" }
    end.with_settings(blast_email_settings(@movement))
  end
end
