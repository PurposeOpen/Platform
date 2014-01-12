require "spec_helper"

describe PaymentErrorMailer do
	before :each do
		@english = create(:english)
		@movement = create(:movement, :name => "testmovement", :slug => "testmovement", :languages => [@english])
		@campaign = create(:campaign, :movement => @movement)
		@action_sequence = create(:published_action_sequence, :campaign => @campaign, :enabled_languages => [@english.iso_code])
    @page = create(:action_page, :name => "Donation page", :action_sequence => @action_sequence)

    ActionMailer::Base.delivery_method = :test
	end

	it "should not send if recipients list is empty" do
		ENV["TESTMOVEMENT_PAYPALERROR_EMAIL_RECIPIENTS"] = ''		
		donation_error = DonationError.new({ :movement => @movement })

		PaymentErrorMailer.report_error(donation_error)

		ActionMailer::Base.deliveries.size.should eql(0)
	end

	it "should send email to single recipient" do
		ENV["TESTMOVEMENT_PAYPALERROR_EMAIL_RECIPIENTS"] = 'test@example.com'
		donation_error = DonationError.new({ 
			:movement => @movement, 
			:action_page => @page,  
			:error_code => '9999',
			:message => 'Error message', 
			:donation_payment_method => 'paypal', 
			:donation_amount_in_cents => 100, 
			:donation_currency => 'USD', 
			:email => 'john.smith@example.com', 
			:first_name => 'John', 
			:last_name => 'Smith', 
			:country_iso => 'ar',
			:locale => 'es'
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
		delivered.should have_body_text(/#{donation_error.member_language_iso}/)
	end

	it "should not include Error Code field if it's empty" do
		ENV["TESTMOVEMENT_PAYPALERROR_EMAIL_RECIPIENTS"] = 'test@example.com'
		donation_error = DonationError.new({
			:movement => @movement,
			:action_page => @page,
			:message => 'Error message',
			:donation_payment_method => 'paypal',
			:donation_amount_in_cents => 100, 
			:donation_currency => 'USD', 
			:email => 'john.smith@example.com', 
			:first_name => 'John', 
			:last_name => 'Smith', 
			:country_iso => 'ar'
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
      donation_error = DonationError.new({:movement => @movement, :action_page => @page })
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
      donation_error = DonationError.new({:movement => @movement, :action_page => @page })
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
      donation_error = DonationError.new({:movement => @movement, :action_page => @page })
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

  describe "recurring_donation_card_declined" do
    let(:donation) { FactoryGirl.create(:recurring_donation) }
    let(:member) { donation.user }
    let(:movement) { donation.user.movement }

    before :each do
      ENV["#{movement.slug}_CONTACT_EMAIL".upcase] = "noreply@#{movement.slug}.org"
      member.update_attribute('country_iso', :us)
      PaymentErrorMailer.recurring_donation_card_declined(donation).deliver
    end

    let(:delivered) { ActionMailer::Base.deliveries.last }

    it "should deliver a single email" do
      ActionMailer::Base.deliveries.size.should == 1
    end

    it "should deliver a single email with the correct to, from, and subject fields" do
      delivered.to.length.should == 1
      delivered.to.first.should == donation.user.email
      delivered.from.length.should == 1
      delivered.from.first.should == "noreply@#{movement.slug}.org"
      delivered.subject.should == "We were unable to process your last gift to #{movement.name}"
    end

    it "should deliver email with the correct body" do
      delivered.should have_body_text("your credit card was declined")
      delivered.should have_body_text("http://www.yourdomain.com/en/actions/unnamed-page-1")
      delivered.should have_body_text(/#{member.first_name}/) if member.first_name.present?
      delivered.should have_body_text(/#{member.last_name}/) if member.last_name.present?
      delivered.should have_body_text(/#{member.postcode}/) if member.postcode.present?
      delivered.should have_body_text(/UNITED STATES/)
      delivered.should have_body_text(/#{member.email}/)
      delivered.should have_body_text("$20.00 #{donation.frequency}")
      delivered.should have_body_text("#{donation.created_at.strftime("%F")}")
      delivered.should have_body_text("#{donation.payment_method_token}")
    end
  end
end
