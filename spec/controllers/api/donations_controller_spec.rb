#encoding: utf-8
require "spec_helper"

describe Api::DonationsController do
	before do
		@english = FactoryGirl.create(:english)
		@movement = FactoryGirl.create(:movement, :name => "All Out", :languages => [@english])
		@one_off_donation = FactoryGirl.create(:donation, :frequency => :one_off, :transaction_id => '1234567', :active => false)
		@monthly_donation = FactoryGirl.create(:donation, :frequency => :monthly, :subscription_id => '2222222', :active => false, :amount_in_cents => 0, :currency => 'USD')
	end

  describe 'show' do
    it "should return donation by subscription id in json format" do
      get :show, :movement_id => @movement.friendly_id, :subscription_id => '2222222'

      data = ActiveSupport::JSON.decode(response.body)
      data["subscription_id"].should eql @monthly_donation.subscription_id
      data["user"]["email"].should eql @monthly_donation.user.email
      data["action_page"]["id"].should eql @monthly_donation.action_page.id
    end

    it "should return 404 when donation is not found" do
      get :show, :movement_id => @movement.friendly_id, :subscription_id => 'Inexistent Donation'
      response.response_code.should eql 404
    end
  end

	describe 'confirm_payment' do
		it "should make one off donation active" do
			post :confirm_payment, :movement_id => @movement.friendly_id, :transaction_id => '1234567'

			response.status.should == 200
			Donation.find(@one_off_donation.id).active.should be_true			      
		end
		
		it "should return 404 if donation with transaction id is not found" do
			post :confirm_payment, :movement_id => @movement.friendly_id, :transaction_id => '9999999'

			response.status.should == 404
		end
	end

	describe 'add_payment' do
		it "should make recurring donation active on first payment" do
			post :add_payment, :movement_id => @movement.friendly_id, :transaction_id => '111111', :subscription_id => '2222222', :order_number => '1001', :amount_in_cents => 1000

			response.status.should == 200
			updated_donation = Donation.find(@monthly_donation.id)
			updated_donation.amount_in_cents.should == 1000
			updated_donation.active.should be_true
		end

		it "should return 404 if donation with subscription id is not found" do
			post :confirm_payment, :movement_id => @movement.friendly_id, :transaction_id => '8888888'

			response.status.should == 404
		end
  end

  describe 'handle_failed_payment' do

    it "should get donation and member information and deliver mail" do

      params = {}
      params[:action_page] = 'donatenow'
      params[:error_code] = 'error_code'
      params[:message] = 'message'
      params[:member_email] = 'john.doe@example.com'
      params[:subscription_id] = '123456789'
      params[:donation_amount_in_cents] = '2000'

      member = OpenStruct.new
      member.first_name = 'John'
      member.last_name = 'Doe'
      member.language = OpenStruct.new
      member.language.iso = 'en'
      member.country_iso = 'us'

      members = mock()
      members.should_receive(:find_by_email).with(params[:member_email]).and_return(member)

      @movement.should_receive(:members).and_return(members)
      @movement.should_receive(:find_published_page).with("#{params[:action_page]}").and_return(mock())
      
      Movement.should_receive(:find).and_return(@movement)

      donation = OpenStruct.new
      donation.currency = 'usd'
      donation.payment_method = 'credit_card'

      Donation.should_receive(:find_by_subscription_id).with(params[:subscription_id]).and_return(donation)

      mailer = mock()
      mailer.should_receive(:report_error)
      PaymentErrorMailer.should_receive(:delay).and_return(mailer)

      post :handle_failed_payment, params.merge({:movement_id=>@movement.id})

      response.status.should == 200
    end

  end

end