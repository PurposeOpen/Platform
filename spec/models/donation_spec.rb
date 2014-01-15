# == Schema Information
#
# Table name: donations
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  content_module_id      :integer          not null
#  amount_in_cents        :integer          not null
#  payment_method         :string(32)       not null
#  frequency              :string(32)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  active                 :boolean          default(TRUE)
#  last_donated_at        :datetime
#  page_id                :integer          not null
#  email_id               :integer
#  recurring_trigger_id   :string(255)
#  last_tried_at          :datetime
#  identifier             :string(255)
#  receipt_frequency      :string(255)
#  flagged_since          :datetime
#  flagged_because        :string(255)
#  dismissed_at           :datetime
#  currency               :string(255)
#  amount_in_dollar_cents :integer
#  order_id               :string(255)
#  transaction_id         :string(255)
#  subscription_id        :string(255)
#  subscription_amount    :integer
#

require "spec_helper"

describe Donation do
  class RecordingGateway < ActiveMerchant::Billing::BogusGateway
    attr_accessor :added_trigger
    def add_trigger(amount, creditcard, options = {})
      @added_trigger = [amount, creditcard, options]
      super(amount, creditcard, options)
    end
    def delete(options={})
      @added_trigger = nil
    end

    def trigger(amount, options = {})
      @added_trigger[0] = amount
      @added_trigger[2] = options

      super(amount, options)
    end
  end


  def validated_donation(attrs={})
    donation = FactoryGirl.build(:donation)
    donation.attributes = attrs
    donation.valid?
    donation
  end

  def existing_recurring_donation(frequency, post_process_attrs)
    donation = FactoryGirl.create(:donation, :frequency => frequency)
    donation.process!
    donation.update_attributes!(post_process_attrs)
    donation.should have(1).transactions
    donation
  end

  before do
    bank = Money::Bank::Base.new
    def bank.exchange_with(from, to_currency)
      return from if same_currency?(from.currency, to_currency)
      Money.new(from.cents * 2)
    end

    Money.default_bank = bank
  end  

  it "should create a user activity event after a new donation is created" do
    user = FactoryGirl.create(:user)
    content_module = FactoryGirl.create(:donation_module)
    page = FactoryGirl.create(:action_page)
    
    donation = FactoryGirl.create(:donation, :user => user, :action_page => page, :content_module => content_module)

    donation_events = UserActivityEvent.where(:user_response_id => donation.id).all
    donation_events.length.should eql 1
    donation_events.first.user.should eql user
    donation_events.first.content_module.should eql content_module
    donation_events.first.page.should eql page
  end

  it "should allow multiple action_taken user activity events for the same user and donation module" do
    user = FactoryGirl.create(:user)
    content_module = FactoryGirl.create(:donation_module)
    page = FactoryGirl.create(:action_page)
    
    first_donation = FactoryGirl.create(:donation, :user => user, :action_page => page, :content_module => content_module)
    second_donation = FactoryGirl.create(:donation, :user => user, :action_page => page, :content_module => content_module)

    UserActivityEvent.where(:user_id => user.id, :page_id => page.id, :activity => 'action_taken',
                            :content_module_id => content_module.id, :user_response_type => 'Donation').all.count.should == 2
  end

  describe "amounts" do
    it "converts user's currency cents into US dollars" do
      donation = FactoryGirl.create(:donation, :currency => :brl, :amount_in_cents => 235)
      donation.amount_in_dollar_cents.should == 470
    
      donation = FactoryGirl.create(:donation, :currency => :brl, :amount_in_cents => 1)
      donation.amount_in_dollar_cents.should == 2

      donation = FactoryGirl.create(:donation, :currency => :brl, :amount_in_cents => "99")
      donation.amount_in_dollar_cents.should == 198

      donation = FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 10)
      donation.amount_in_dollar_cents.should == 10
    end
  end
  
  describe "validation" do
    it "must have a positive amount_in_cents" do
      validated_donation(:amount_in_cents => "10.99").should be_valid
      validated_donation(:amount_in_cents => "0.0").should_not be_valid
      validated_donation(:amount_in_cents => "Ten").should_not be_valid
    end

    it "must have amount_in_cents if active" do
      validated_donation(:amount_in_cents => 0, :active => false).should be_valid
      validated_donation(:amount_in_cents => 0, :active => true).should_not be_valid
      validated_donation(:amount_in_cents => 100, :active => true).should be_valid
    end

    it "must have transaction_id if one off" do
      validated_donation(:frequency => :one_off, :transaction_id => '123456').should be_valid
      validated_donation(:frequency => :one_off, :transaction_id => nil).should_not be_valid
    end

    it "can have nil transaction_id if recurring" do
      validated_donation(:frequency => :monthly, :subscription_id => '123456', :transaction_id => '654321').should be_valid
      validated_donation(:frequency => :monthly, :subscription_id => '123456', :transaction_id => nil).should be_valid
    end
  end

  describe "stats_by_action_page" do

    it "should calculate donation stats by page" do
      a_page = FactoryGirl.create(:action_page)
      a_module = FactoryGirl.create(:donation_module, :pages => [a_page])
      another_page = FactoryGirl.create(:action_page)
      another_module = FactoryGirl.create(:donation_module, :pages => [another_page])

      FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 500, :content_module => a_module, :action_page => a_page)
      FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 700, :content_module => a_module, :action_page => a_page)
      FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 200, :content_module => another_module, :action_page => another_page)

      Donation.stats_by_action_page(a_page.id)[0].should == 2
      Donation.stats_by_action_page(a_page.id)[1].should == 1200

      Donation.stats_by_action_page(another_page.id)[0].should == 1
      Donation.stats_by_action_page(another_page.id)[1].should == 200

    end

    it "should return zero if no donations" do
      a_page = FactoryGirl.create(:action_page)
      a_module = FactoryGirl.create(:donation_module, :pages => [a_page])

      Donation.stats_by_action_page(a_page.id)[0].should == 0
      Donation.stats_by_action_page(a_page.id)[1].should == 0
    end

  end
  describe "#made_to" do
    it "should return the campaign the donation was made to" do
      donation = FactoryGirl.create(:donation, :frequency => "monthly", :subscription_id => '12345')
      donation.made_to.should eql "Dummy Campaign Name"
    end
  end

  it "should calculate the total of donations by page" do
    a_page = FactoryGirl.create(:action_page)
    a_module = FactoryGirl.create(:donation_module, :pages => [a_page])
    another_page = FactoryGirl.create(:action_page)
    another_module = FactoryGirl.create(:donation_module, :pages => [another_page])

    FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 500, :content_module => a_module, :action_page => a_page)
    FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 700, :content_module => a_module, :action_page => a_page)
    FactoryGirl.create(:donation, :currency => :usd, :amount_in_cents => 200, :content_module => another_module, :action_page => another_page)

    Donation.total_in_dollar_cents_by_action_page(a_page.id).should == 1200
    Donation.total_in_dollar_cents_by_action_page(another_page.id).should == 200
  end

  it "should provide receipt information as a token for autofire emails" do
    a_page = FactoryGirl.create(:action_page)
    a_language = FactoryGirl.create(:language, :iso_code => 'en')
    a_module = FactoryGirl.create(:donation_module, :pages => [a_page], :language => a_language)
    a_user = FactoryGirl.create(:user, :first_name => 'Don', :last_name => 'Ramon', :postcode => '10010', :movement => a_page.movement)

    donation = FactoryGirl.create(:donation,
        :currency => :brl,
        :amount_in_cents => 500000,
        :order_id => 'order123',
        :transaction_id => 'transaction123',
        :frequency => 'one_off',
        :user => a_user,
        :content_module => a_module,
        :action_page => a_page)

    donation.autofire_tokens.should == {
      'DONATION_FREQUENCY'=> '',
      'DONATION_AMOUNT' => 'R$ 5,000.00',
      'DONATION_DATE' => Date.today.to_s,
      'DONATION_TRANSACTION_ID' => 'Transaction ID: transaction123',
      'DONATION_CANCELLATION' => ' '
    }
  end

  it "should provide receipt information (considering donation frequency) as a token for autofire emails" do
    a_page = FactoryGirl.create(:action_page)
    a_language = FactoryGirl.create(:language, :iso_code => 'en')
    a_module = FactoryGirl.create(:donation_module, :pages => [a_page], :language => a_language)
    a_user = FactoryGirl.create(:user, :first_name => 'Don', :last_name => 'Ramon', :postcode => '10010', :movement => a_page.movement)

    donation = FactoryGirl.create(:donation,
                                  :currency => :brl,
                                  :amount_in_cents => 500000,
                                  :subscription_amount => 100000,
                                  :frequency => 'monthly',
                                  :order_id => 'order123',
                                  :transaction_id => 'transaction123',
                                  :subscription_id => 'transaction123',
                                  :user => a_user,
                                  :content_module => a_module,
                                  :action_page => a_page)

    donation.autofire_tokens.should == {
        'DONATION_FREQUENCY'=> 'monthly',
        'DONATION_AMOUNT' => 'R$ 1,000.00',
        'DONATION_DATE' => Date.today.to_s,
        'DONATION_TRANSACTION_ID' => 'Transaction ID: transaction123',
        'DONATION_CANCELLATION' => 'To cancel or modify your recurring donation, email us at donate@allout.org'
    }
  end

  describe "add_payment" do
    it "should create transaction for a recurring donation" do
      recurring_donation = FactoryGirl.create(:recurring_donation)
      transaction = mock()
      Transaction.should_receive(:new).with(:donation => recurring_donation,
          :external_id => recurring_donation.transaction_id,
          :invoice_id => recurring_donation.order_id,
          :amount_in_cents => recurring_donation.amount_in_cents,
          :currency => recurring_donation.currency,
          :successful => true).and_return(transaction)

      transaction.should_receive(:save!)

      transaction_id = recurring_donation.transaction_id
      invoice_id = nil
      recurring_donation.add_payment(recurring_donation.amount_in_cents, transaction_id, invoice_id)
    end

    it "should update the last_donated_at attribute on the donation" do
      recurring_donation = FactoryGirl.create(:recurring_donation)
      transaction = recurring_donation.add_payment(recurring_donation.subscription_amount, recurring_donation.transaction_id, nil)
      recurring_donation.last_donated_at.to_i.should == transaction.created_at.to_i
    end

    it "should add payment amount to donation when amount is zero" do
      donation = FactoryGirl.create(:donation)
      donation.update_attribute('amount_in_cents', 0)
      donation.amount_in_cents.should == 0

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(100, transaction_id, invoice_id)

      donation.amount_in_cents.should == 100
      donation.amount_in_dollar_cents.should == 100
    end

    it "should add payment amount to donation when amount is greater than zero" do
      donation = FactoryGirl.create(:donation)
      donation.amount_in_cents.should == 1000
      donation.amount_in_dollar_cents.should == 1000

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(800, transaction_id, invoice_id)

      donation.amount_in_cents.should == 1800
      donation.amount_in_dollar_cents.should == 1800
    end

    it "should activate donation on initial payment" do
      donation = FactoryGirl.create(:donation, :active => false)
      donation.active.should be_false

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(100, transaction_id, invoice_id)

      donation.active.should be_true
    end
  end

  describe "a donation created via take action" do
    let(:user) { FactoryGirl.create(:english_user, :email => 'noone@example.com') }
    let(:ask) { FactoryGirl.create(:donation_module) }
    let(:page) { FactoryGirl.create(:action_page) }
    let(:email) { FactoryGirl.create(:email) }
    let(:action_info) { valid_donation_action_info }
    let(:successful_purchase) { successful_purchase_and_hash_response }
    let(:failed_purchase) { failed_purchase_and_hash_response }

    before :each do
      mailer = mock
      PaymentMailer.stub(:confirm_purchase) { mailer }
      mailer.stub(:deliver)
    end

    describe "confirm" do
      let(:donation) { FactoryGirl.create(:donation, :active => false) }

      before :each do
        donation.active.should be_false
      end

      it "should mark as active" do
        donation.confirm
        donation.active.should be_true
      end

      it "should send purchase confirmation email" do
        PaymentMailer.should_receive(:confirm_purchase)
        donation.confirm
        donation.transactions.count.should == 1
      end
    end

    # a donation created via take_action
    describe "#make_payment_on_recurring_donation" do
      let(:donation) { ask.take_action(user, action_info, page) }
      let(:stubbed_client) { SpreedlyClient.stub(:new) { nil } }

      it "should not call SpreedlyClient.purchase_and_hash_response if the frequency is :one_off" do
        donation.update_attribute('frequency', :one_off)
        donation.make_payment_on_recurring_donation
        SpreedlyClient.should_not_receive(:purchase_and_hash_response)
      end

      it "should not call SpreedlyClient.purchase_and_hash_response if the donation is inactive" do
        donation.update_attribute(:active, false)
        SpreedlyClient.should_not_receive(:purchase_and_hash_response)
        donation.make_payment_on_recurring_donation
      end

      it "should call #handle_successful_spreedly_purchase_on_recurring_donation after a successful purchase" do
        stubbed_client.stub(:create_payment_method_and_purchase) { successful_purchase }
        SpreedlyClient.stub(:new) { stubbed_client }
        donation.should_receive(:handle_successful_spreedly_purchase_on_recurring_donation).with(successful_purchase)
        donation.make_payment_on_recurring_donation
      end

      it "should call #handle_failed_recurring_payment for an unsuccessful payment" do
        stubbed_client.stub(:create_payment_method_and_purchase) { failed_purchase }
        SpreedlyClient.stub(:new) { stubbed_client }
        donation.should_receive(:handle_failed_recurring_payment)
        donation.make_payment_on_recurring_donation
      end
    end

    # a donation created via take_action
    describe "#handle_successful_spreedly_purchase_on_recurring_donation" do
      let(:donation) { ask.take_action(user, action_info, page) }
      let(:mailer) { mock }
      let(:spreedly_client_purchase) { successful_purchase }

      before :each do
        mailer.stub(:deliver)
      end

      it "should call #add_payment" do
        donation.stub(:enqueue_recurring_payment)
        PaymentMailer.stub(:confirm_recurring_purchase) { mailer }
        donation.should_receive(:add_payment)
        donation.handle_successful_spreedly_purchase_on_recurring_donation(spreedly_client_purchase)
      end

      it "should call #enqueue_recurring_payment" do
        PaymentMailer.stub(:confirm_recurring_purchase) { mailer }
        donation.should_receive(:enqueue_recurring_payment)
        donation.handle_successful_spreedly_purchase_on_recurring_donation(spreedly_client_purchase)
      end

      it "should send payment confirmation email" do
        transaction = donation.add_payment(donation.amount_in_cents, donation.transaction_id, nil)
        donation.stub(:enqueue_recurring_payment)
        donation.stub(:add_payment) { transaction }
        PaymentMailer.should_receive(:confirm_recurring_purchase).with(donation, transaction).and_return(mailer)
        donation.handle_successful_spreedly_purchase_on_recurring_donation(spreedly_client_purchase)
      end

      it "should create transactions with the subscription amount and increment the donation amount" do
        donation.stub(:enqueue_recurring_payment)
        PaymentMailer.stub(:confirm_recurring_purchase) { mailer }
        donation.transactions.count.should == 1

        2.times { donation.handle_successful_spreedly_purchase_on_recurring_donation(spreedly_client_purchase) }

        donation.transactions.count.should == 3
        donation.subscription_amount.should == 100
        donation.amount_in_cents.should == 300

        donation.transactions.each { |t| t.amount_in_cents.should == 100 }
      end
    end

    # a donation created via take action
    describe "enqueue_recurring_payment" do
      let(:donation) { ask.take_action(user, action_info, page) }

      it "calls Resque.enqueue when a monthly recurring donation is active" do
        donation.active.should == true
        Resque.should_receive(:enqueue)
        donation.enqueue_recurring_payment
      end

      it "does not call Resque.enqueue when a recurring donation is inactive" do
        donation.update_attribute('active', :false)
        Resque.should_not_receive(:enqueue)
        donation.enqueue_recurring_payment
      end

      it "does not call Resque.enqueue for a one_off donation" do
        donation.update_attribute('frequency', :one_off)
        Resque.should_not_receive(:enqueue)
        donation.enqueue_recurring_payment
      end

      it "should not call the expiring card email when the card will be valid for the next payment" do
        card_expiring_this_month = { :month => DateTime.now.month, :year => DateTime.now.year }
        donation.update_attributes(
          :frequency => 'weekly',
          :card_exp_month => card_expiring_this_month[:month],
          :card_exp_year => card_expiring_this_month[:year]
        )

        next_payment = DateTime.now.end_of_month - 1.week
        DateTime.stub(:now) { next_payment }
        Resque.stub(:enqueue) { nil }
        mailer = mock
        mailer.stub(:deliver)

        PaymentMailer.should_not_receive(:expiring_credit_card).with(donation).and_return(mailer)
        donation.enqueue_recurring_payment
      end

      it "should call the expiring card email when the card expires before the next weekly payment" do
        card_expiring_this_month = { :month => DateTime.now.month, :year => DateTime.now.year }
        donation.update_attributes(
          :frequency => 'weekly',
          :card_exp_month => card_expiring_this_month[:month],
          :card_exp_year => card_expiring_this_month[:year]
        )

        next_payment = DateTime.now.end_of_month - 6.days
        DateTime.stub(:now) { next_payment }
        Resque.stub(:enqueue) { nil }
        mailer = mock
        mailer.stub(:deliver)

        PaymentMailer.should_receive(:expiring_credit_card).with(donation).and_return(mailer)
        donation.enqueue_recurring_payment
      end
    end

    # a donation created via take action
    describe "#deactivate" do
      let(:donation) { ask.take_action(user, action_info, page) }

      it "sets the active attribute to false for a donation" do
        donation.active.should == true
        donation.deactivate
        donation.active.should == false
      end
    end

    # a donation created via take action
    describe "#handle_failed_recurring_payment" do
      let(:donation) { ask.take_action(user, action_info, page) }
      let(:transaction) { failed_purchase }

      it "should call deactivate on the donation" do
        mailer = mock
        mailer.stub(:recurring_donation_card_declined)
        PaymentErrorMailer.stub(:delay) { mailer }
        donation.should_receive(:deactivate)
        donation.handle_failed_recurring_payment(transaction)
      end

      it "should call PaymentErrorMailer.delay.recurring_donation_card_declined" do
        PaymentErrorMailer.stub(:delay)
        PaymentErrorMailer.delay.should_receive(:recurring_donation_card_declined).with(donation)
        donation.handle_failed_recurring_payment(failed_purchase)
      end
    end
  end
end
