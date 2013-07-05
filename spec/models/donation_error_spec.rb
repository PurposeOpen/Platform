require "spec_helper"

describe DonationError do
	context 'initialization' do
		it "should initialize all attributes from hash" do
			english = create(:english)
			movement = create(:movement, :name => "All Out", :languages => [english])
			campaign = create(:campaign, :movement => movement)
			action_sequence = create(:published_action_sequence, :campaign => campaign, :enabled_languages => [english.iso_code])
	    page = create(:action_page, :name => "Donation page", :action_sequence => action_sequence)
			attributes_hash = { :movement => movement, :action_page => page, :error_code => '9999', :message => 'Error message', :donation_payment_method => 'paypal', :donation_amount_in_cents => 100, :donation_currency => 'USD', :email => 'john.smith@example.com', :first_name => 'John', :last_name => 'Smith', :country_iso => 'ar', :locale => 'es', :postcode => '1111' }

			donation_error = DonationError.new attributes_hash

			donation_error.movement.should eql movement
			donation_error.action_page.should eql page
			donation_error.error_code.should eql '9999'
			donation_error.message.should eql 'Error message'
			donation_error.donation_payment_method.should eql 'paypal'
			donation_error.donation_amount_in_cents.should eql 100
			donation_error.donation_currency.should eql 'USD'
			donation_error.member_email.should eql 'john.smith@example.com'
			donation_error.member_first_name.should eql 'John'
			donation_error.member_last_name.should eql 'Smith'
			donation_error.member_country_iso.should eql 'ar'
			donation_error.member_language_iso.should eql 'es'
		end

		it "should initialize member attributes even if not present on hash" do
			english = create(:english)
			movement = create(:movement, :name => "All Out", :languages => [english])
			campaign = create(:campaign, :movement => movement)
			action_sequence = create(:published_action_sequence, :campaign => campaign, :enabled_languages => [english.iso_code])
	    page = create(:action_page, :name => "Donation page", :action_sequence => action_sequence)
			attributes_hash = { :movement => movement, :action_page => page, :error_code => '8888', :message => 'Error message', :donation_payment_method => 'paypal', :donation_amount_in_cents => 100, :donation_currency => 'USD' }

			donation_error = DonationError.new attributes_hash

			donation_error.movement.should eql movement
			donation_error.action_page.should eql page
			donation_error.error_code.should eql '8888'
			donation_error.message.should eql 'Error message'
			donation_error.donation_payment_method.should eql 'paypal'
			donation_error.donation_amount_in_cents.should eql 100
			donation_error.donation_currency.should eql 'USD'
			donation_error.member_email.should be_empty
			donation_error.member_first_name.should be_empty
			donation_error.member_last_name.should be_empty
			donation_error.member_country_iso.should be_empty
			donation_error.member_language_iso.should eql 'en'
		end

		it "should not throw error if attributes hash is empty" do
			lambda { DonationError.new({}) }.should_not raise_exception
		end

		it "should not throw error if attributes hash is nil" do
			lambda { DonationError.new(nil) }.should_not raise_exception
		end

		it "should not throw if error_code is not present on hash" do
			english = create(:english)
			movement = create(:movement, :name => "All Out", :languages => [english])
			campaign = create(:campaign, :movement => movement)
			action_sequence = create(:published_action_sequence, :campaign => campaign, :enabled_languages => [english.iso_code])
	    page = create(:action_page, :name => "Donation page", :action_sequence => action_sequence)
			attributes_hash = { :movement => movement, :action_page => page, :message => 'Error message', :donation_payment_method => 'paypal', :donation_amount_in_cents => 100, :donation_currency => 'USD', :email => 'john.smith@example.com', :first_name => 'John', :last_name => 'Smith', :country_iso => 'ar', :postcode => '1111' }

			donation_error = DonationError.new attributes_hash

			donation_error.error_code.should be_empty

			donation_error.movement.should eql movement
			donation_error.action_page.should eql page
			donation_error.message.should eql 'Error message'
			donation_error.donation_payment_method.should eql 'paypal'
			donation_error.donation_amount_in_cents.should eql 100
			donation_error.donation_currency.should eql 'USD'
			donation_error.member_email.should eql 'john.smith@example.com'
			donation_error.member_first_name.should eql 'John'
			donation_error.member_last_name.should eql 'Smith'
			donation_error.member_country_iso.should eql 'ar'
		end
	end
end