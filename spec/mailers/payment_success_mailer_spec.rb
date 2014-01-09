require 'spec_helper'

class PaymentSuccessMailer do
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
		spreedly_transaction = DonationError.new({ :movement => @movement })
		PaymentSuccessMailer.confirm_recurring_payment_purchase(spreedly_transaction)

		ActionMailer::Base.deliveries.size.should == 0
	end
end
