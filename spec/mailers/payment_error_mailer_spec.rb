require "spec_helper"

describe PaymentErrorMailer do
	before :each do
		@english = create(:english)
		@movement = create(:movement, name: "testmovement", slug: "testmovement", languages: [@english])
		@campaign = create(:campaign, movement: @movement)
		@action_sequence = create(:published_action_sequence, campaign: @campaign, enabled_languages: [@english.iso_code])
    @page = create(:action_page, name: "Donation page", action_sequence: @action_sequence)

    ActionMailer::Base.delivery_method = :test
	end

	it "should not send if recipients list is empty" do
		ENV["TESTMOVEMENT_PAYPALERROR_EMAIL_RECIPIENTS"] = ''		
		donation_error = DonationError.new({ movement: @movement })

		PaymentErrorMailer.report_error(donation_error)

		ActionMailer::Base.deliveries.size.should eql(0)
	end

	it "should send email to single recipient" do
		ENV["TESTMOVEMENT_PAYPALERROR_EMAIL_RECIPIENTS"] = 'test@example.com'
		donation_error = DonationError.new({ 
			movement: @movement, 
			action_page: @page,  
			error_code: '9999',
			message: 'Error message', 
			donation_payment_method: 'paypal', 
			donation_amount_in_cents: 100, 
			donation_currency: 'USD', 
			email: 'john.smith@example.com', 
			first_name: 'John', 
			last_name: 'Smith', 
			country_iso: 'ar'
		})

		PaymentErrorMailer.report_error(donation_error).deliver

		ActionMailer::Base.deliveries.size.should eql(1)
		delivered = ActionMailer::Base.deliveries.last

		delivered.to.should include 'test@example.com'
		delivered.subject.should eql PaymentErrorMailer::DEFAULT_SUBJECT % donation_error.movement.name
		delivered.should have_body_text(/#{donation_error.action_page.name}/)
		delivered.should have_body_text(/#{donation_error.error_code}/)
		delivered.should have_body_text(/#{donation_error.message}/)
		delivered.should have_body_text(/#{donation_error.donation_payment_method}/)
		delivered.should have_body_text(/#{donation_error.donation_amount_in_cents}/)
		delivered.should have_body_text(/#{donation_error.donation_currency}/)
		delivered.should have_body_text(/#{donation_error.member_email}/)
		delivered.should have_body_text(/#{donation_error.member_first_name}/)
		delivered.should have_body_text(/#{donation_error.member_last_name}/)
		delivered.should have_body_text(/#{donation_error.member_country_iso}/)
	end

	it "should not include Error Code field if it's empty" do
		ENV["TESTMOVEMENT_PAYPALERROR_EMAIL_RECIPIENTS"] = 'test@example.com'
		donation_error = DonationError.new({
			movement: @movement,
			action_page: @page,
			message: 'Error message',
			donation_payment_method: 'paypal',
			donation_amount_in_cents: 100, 
			donation_currency: 'USD', 
			email: 'john.smith@example.com', 
			first_name: 'John', 
			last_name: 'Smith', 
			country_iso: 'ar'
		})

		PaymentErrorMailer.report_error(donation_error).deliver

		ActionMailer::Base.deliveries.size.should eql(1)
		delivered = ActionMailer::Base.deliveries.last

		delivered.should_not have_body_text(/- Code:/i)
  end

  describe "report_error_to_member" do

    before do
      ENV["#{@movement.slug}_CONTACT_EMAIL".upcase] = "noreply@#{@movement.slug}.org"
    end

    it "should deliver mail to member email address with the localized subject" do
      donation_error = DonationError.new({movement: @movement, action_page: @page })
      donation_error.message = 'Error message'
      donation_error.reference = 'reference'
      donation_error.donation_payment_method = 'credit_card'
      donation_error.donation_amount_in_cents = 100
      donation_error.donation_currency = 'usd'
      donation_error.member_email = 'john.smith@example.com'
      donation_error.member_first_name = 'John'
      donation_error.member_last_name = 'Smith'
      donation_error.member_language_iso = 'en'

      PaymentErrorMailer.report_error_to_member(donation_error).deliver

      ActionMailer::Base.deliveries.size.should eql(1)
      delivered = ActionMailer::Base.deliveries.last

      delivered.to.should include donation_error.member_email
      delivered.subject.should eql "Error: Your monthly gift to testmovement did not process"

    end

    it "should include members info in the message body" do
      donation_error = DonationError.new({movement: @movement, action_page: @page })
      donation_error.message = 'Error message'
      donation_error.reference = '123456'
      donation_error.donation_payment_method = 'credit_card'
      donation_error.donation_amount_in_cents = 100
      donation_error.donation_currency = 'usd'
      donation_error.member_email = 'john.smith@example.com'
      donation_error.member_first_name = 'John'
      donation_error.member_last_name = 'Smith'
      donation_error.member_language_iso = 'en'

      PaymentErrorMailer.report_error_to_member(donation_error).deliver

      ActionMailer::Base.deliveries.size.should eql(1)
      delivered = ActionMailer::Base.deliveries.last

      delivered.should have_body_text(/#{donation_error.member_first_name}/)
      delivered.should have_body_text(/#{donation_error.member_last_name}/)
    end

    it "should include reference number and contact email in the message body" do
      donation_error = DonationError.new({movement: @movement, action_page: @page })
      donation_error.message = 'Error message'
      donation_error.reference = '123456'
      donation_error.donation_payment_method = 'credit_card'
      donation_error.donation_amount_in_cents = 100
      donation_error.donation_currency = 'usd'
      donation_error.member_email = 'john.smith@example.com'
      donation_error.member_first_name = 'John'
      donation_error.member_last_name = 'Smith'
      donation_error.member_language_iso = 'en'

      PaymentErrorMailer.report_error_to_member(donation_error).deliver

      ActionMailer::Base.deliveries.size.should eql(1)
      delivered = ActionMailer::Base.deliveries.last

      delivered.should have_body_text(/#{donation_error.reference}/)
      delivered.should have_body_text(/#{ENV["#{donation_error.movement.slug}_CONTACT_EMAIL".upcase]}/)
    end

  end
end