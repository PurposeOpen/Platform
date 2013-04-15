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
#  card_type              :string(32)
#  card_expiry_month      :integer
#  card_expiry_year       :integer
#  card_last_four_digits  :string(4)
#  name_on_card           :string(255)
#  active                 :boolean          default(TRUE)
#  last_donated_at        :datetime
#  page_id                :integer          not null
#  email_id               :integer
#  cheque_number          :string(128)
#  cheque_name            :string(255)
#  cheque_bank            :string(255)
#  cheque_branch          :string(255)
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

    it "must have subscription_id if recurring" do
      validated_donation(:frequency => :monthly, :subscription_id => '123456').should be_valid
      validated_donation(:frequency => :monthly, :subscription_id => nil).should_not be_valid
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

  describe "confirm" do
    it "should mark as active" do
      donation = FactoryGirl.create(:donation, :active => false, :order_id => '1123789', :transaction_id => "23423434")

      donation.active.should be_false

      donation.confirm

      donation.active.should be_true
    end
  end

  describe "add_payment" do

    it "should create transaction" do

      donation = FactoryGirl.create(:donation, :active => false, :frequency => :monthly, :amount_in_cents => 10, :currency => 'usd', :subscription_id => '12345', :order_id => '1123789', :transaction_id => "23423434")

      transaction = mock()
      Transaction.should_receive(:new).with(:donation => donation,
          :external_id => donation.transaction_id,
          :invoice_id => donation.order_id,
          :amount_in_cents => 100,
          :currency => donation.currency,
          :successful => true).and_return(transaction)

      transaction.should_receive(:save!)

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(100, transaction_id, invoice_id)

    end

    it "should add payment amount to donation when amount is zero" do
      donation = FactoryGirl.create(:donation, :active => false, :frequency => :monthly, :amount_in_cents => 0, :currency => 'usd', :subscription_id => '12345', :order_id => '1123789', :transaction_id => "23423434")

      donation.amount_in_cents.should == 0

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(100, transaction_id, invoice_id)

      donation.amount_in_cents.should == 100
      donation.amount_in_dollar_cents.should == 100
    end

    it "should add payment amount to donation when amount is greater than zero" do
      donation = FactoryGirl.create(:donation, :active => false, :frequency => :monthly, :amount_in_cents => 100, :currency => 'usd', :subscription_id => '12345', :order_id => '1123789', :transaction_id => "23423434")

      donation.amount_in_cents.should == 100
      donation.amount_in_dollar_cents.should == 100

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(800, transaction_id, invoice_id)

      donation.amount_in_cents.should == 900
      donation.amount_in_dollar_cents.should == 900
    end

    it "should activate donation on initial payment" do
      donation = FactoryGirl.create(:donation, :active => false, :frequency => :monthly, :amount_in_cents => 0, :currency => 'usd', :subscription_id => '12345', :order_id => '1123789', :transaction_id => "23423434")

      donation.active.should be_false

      transaction_id = "23423434"
      invoice_id = "1123789"
      donation.add_payment(100, transaction_id, invoice_id)

      donation.active.should be_true
    end
  end
end
