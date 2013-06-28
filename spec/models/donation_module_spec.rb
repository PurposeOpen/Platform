# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

require "spec_helper"

describe DonationModule do

  def validated_donation_module(attrs)
    default_attrs = {
      active: 'true', 
      :default_currency => 'usd', 
      :suggested_amounts => {'usd' => '1,2,3'}, 
      :default_amount => {'usd' => '1'}, 
      :donations_goal => 10, 
      :thermometer_threshold => 0
    }
    etm = FactoryGirl.build(:donation_module, default_attrs.merge(attrs))
    etm.valid_with_warnings?
    etm
  end

  it "should create sensible defaults" do
    DonationModule::AVAILABLE_CURRENCIES = { :usd => Money::Currency.new('USD') }
    dm = DonationModule.create
    dm.button_text.should == 'Donate!'
    dm.suggested_amounts.should == {}
    dm.default_amount.should == {}
    dm.recurring_suggested_amounts.should == {}
    dm.recurring_default_amount.should == {}
  end

  it "should remove whitespace from suggested_amounts" do
    dm = FactoryGirl.create(:donation_module, :suggested_amounts => {'usd' => '1 , 2,3'}, :default_amount => {'usd' => '1'}, :donations_goal => 10, :thermometer_threshold => 0)
    dm.suggested_amounts['usd'].should == '1,2,3'
  end

  it "should remove whitespace from recurring_suggested_amounts" do
    dm = FactoryGirl.create(:donation_module, :recurring_suggested_amounts => {'monthly' => {'usd' => '1 , 2, 3 '}}, :default_amount => {'usd' => '1'}, :donations_goal => 10, :thermometer_threshold => 0)
    dm.recurring_suggested_amounts['monthly']['usd'].should == '1,2,3'
  end

  describe "validations" do
    it "should add a warning if title is not between 3 and 128 characters" do
      validated_donation_module(:title => "Save the kittens!").should be_valid_with_warnings
      validated_donation_module(:title => "X" * 128).should be_valid_with_warnings
      validated_donation_module(:title => "X" * 129).errors[:title].should_not be_empty
      validated_donation_module(:title => "AB").errors[:title].should_not be_empty
    end

    it "should add a warning if thermometer threshold is not greater than or equal to 0" do
      validated_donation_module(:thermometer_threshold => 1, :donations_goal => 2).should be_valid_with_warnings
      validated_donation_module(:thermometer_threshold => 0, :donations_goal => 1).should be_valid_with_warnings
      validated_donation_module(:thermometer_threshold => -1, :donations_goal => 1).should_not be_valid_with_warnings
    end

    it "attribute setter should set goal to 0 if blank or nil, and it should be valid without warnings" do
      dm = validated_donation_module(:donations_goal => nil, :thermometer_threshold => 0)
      dm.donations_goal.should == 0
      dm.should be_valid_with_warnings
    end

    it "should add a warning if donations goal is set to a lower value than the threshold" do
      validated_donation_module(:donations_goal => 10, :thermometer_threshold => 15).errors[:thermometer_threshold].should_not be_empty
      validated_donation_module(:donations_goal => 10, :thermometer_threshold => 10).should be_valid_with_warnings
      validated_donation_module(:donations_goal => 10, :thermometer_threshold => 5).should be_valid_with_warnings
    end

    it "should add warnings unless suggested_amounts and default_amount are present for at least one currency on one-off donations" do
      messages = ["A Suggested and Default amount is required for at least one currency for one-off donations."]
      dm = DonationModule.new
      dm.default_currency = 'USD'
      dm.valid_with_warnings?
      (dm.errors.full_messages & messages).should =~ messages
    end

    it "should add warnings unless suggested_amounts and default_amount are present for at least one currency on recurring donations" do
      messages = ["A Suggested and Default amount is required for at least one currency for recurring donations."]
      dm = DonationModule.new
      dm.recurring_default_currency = 'USD'
      dm.valid_with_warnings?
      (dm.errors.full_messages & messages).should =~ messages
    end

    it "should add a warning unless each suggested amount is an integer greater than 0 and not blank" do
      validated_donation_module(:default_amount => {'usd' => "30"}, :suggested_amounts => {'usd' => "10, 20, 30"}).should be_valid_with_warnings
      validated_donation_module(:default_amount => {'usd' => "30"}, :suggested_amounts => {'usd' =>"0, 30"}).errors[:suggested_amounts].should_not be_empty
      validated_donation_module(:default_amount => {'usd' => "30", 'aud' => "30"}, :suggested_amounts => {'usd' => "10, 20, 30, ABCDEF", 'aud' => ''}).errors[:suggested_amounts].include?("for USD must be greater than zero.").should be_true
    end

    it "should add a warning unless default amount is one of the suggested amounts" do
      validated_donation_module(:default_amount => {'usd' => "10"}, :suggested_amounts => {'usd' =>"10, 20, 30"}).should be_valid_with_warnings
      validated_donation_module(:default_amount => {'usd' => "50", 'aud' => '5'}, :suggested_amounts => {'usd' => "10, 20, 30", 'aud' => '10'}).errors[:default_amount].include?("for USD, AUD must be one of the suggested amounts.").should be_true
    end

    it "should add a warning unless recurring default amount is one of the recurring suggested amounts" do
      validated_donation_module(:recurring_default_amount => {'monthly' => {}},
                                      :recurring_suggested_amounts => {'monthly' => {}}).should be_valid_with_warnings

      validated_donation_module(:recurring_default_amount => {'monthly' => {'usd' => "10"}},
                                :recurring_suggested_amounts => {'monthly' => {'usd' =>"10, 20, 30"}}).should be_valid_with_warnings

      validated_donation_module(:recurring_default_amount => {'monthly' => {}},
                                :recurring_suggested_amounts => {'monthly' => {'usd' =>"10, 20, 30"}}).errors[:recurring_default_amount].include?("for Monthly USD must be one of the suggested amounts.").should be_true

      validated_donation_module(:recurring_default_amount => {'monthly' => {'usd' => "11"}},
                                :recurring_suggested_amounts => {'monthly' => {'usd' =>"10, 20, 30"}}).errors[:recurring_default_amount].include?("for Monthly USD must be one of the suggested amounts.").should be_true
    end

    it "should add a warning if default amount for a currency is not present" do
      dm = validated_donation_module(:default_amount => {'usd' => "20"},
          :suggested_amounts => {'usd' => "10, 20, 30", 'aud' => '10'})

      dm.errors[:default_amount].include?("for AUD must be one of the suggested amounts.").should be_true
    end

    it "should add a warning unless a single default frequency is selected" do
      validated_donation_module(:frequency_options => {'one_off' => 'default', 'weekly' => 'optional'}).should be_valid_with_warnings
      validated_donation_module(:frequency_options => {'one_off' => 'default', 'weekly' => 'default'}).errors[:frequency_options].include?("must have a single default selected.").should be_true
      validated_donation_module(:frequency_options => {'one_off' => 'hidden', 'weekly' => 'optional'}).errors[:frequency_options].include?("must have a single default selected.").should be_true
    end

    it "frequency's default currency and suggested amounts should be set if it's default option" do
      dm = DonationModule.new
      dm.default_frequency = :monthly
      dm.recurring_default_currency = nil
      dm.recurring_suggested_amounts = {}

      dm.should_not be_valid_with_warnings
      dm.errors.full_messages.include?("Recurring default currency must be set if default frequency is recurring").should be_true

      dm.recurring_default_currency = 'USD'
      dm.should_not be_valid_with_warnings
      dm.errors.full_messages.include?("A Suggested and Default amount is required for at least one currency for recurring donations.").should be_true

      dm.recurring_suggested_amounts = {'monthly' => {'usd' =>"10, 20, 30"}}
      dm.should_not be_valid_with_warnings
    end

    it "should not warn if default currency for one-off is not set but recurring is" do
      donation_module = DonationModule.new
      donation_module.default_currency = nil
      donation_module.default_frequency = :monthly
      donation_module.recurring_default_currency = 'USD'
      donation_module.should_not be_valid_with_warnings
      donation_module.errors[:default_currency].any?.should be_false
    end

    it "should not warn if default currency for recurring is not set but one-off is" do
      donation_module = DonationModule.new
      donation_module.default_currency = 'USD'
      donation_module.recurring_default_currency = nil
      donation_module.should_not be_valid_with_warnings
      donation_module.errors[:recurring_default_currency].any?.should be_false
    end

    it "sets once as the default frequency" do
      donation_module = DonationModule.new
      donation_module.receipt_frequency.should == :once
    end

    it "sets default frequency options with once as selected" do
      donation_module = DonationModule.new
      options = {'one_off' => 'default', 'weekly' => 'hidden', 'monthly' => 'optional', 'annual' => 'hidden'}
      donation_module.frequency_options.should == options
    end

    it "commence_donation_at is blank by default" do
      donation_module = DonationModule.new
      donation_module.commence_donation_at.should be_blank
    end

    it "should required disabled title/content if disabled" do
      validated_donation_module(active: 'true', disabled_title: '', disabled_content:
        '').should be_valid_with_warnings
      validated_donation_module(active: 'false', disabled_title: '', disabled_content:
        'bar').should_not be_valid_with_warnings
      validated_donation_module(active: 'false', disabled_title: 'foo', disabled_content:
        '').should_not be_valid_with_warnings
      validated_donation_module(active: 'false', disabled_title: 'foo', disabled_content:
        'bar').should be_valid_with_warnings
    end
  end

  it "should remove whitespace from the suggested amounts string before saving" do
    dm = FactoryGirl.build(:donation_module, :suggested_amounts => {'usd' => '1,   2 ,   3  '}, :default_amount => {'usd' => '1'})
    dm.save!

    dm.suggested_amounts.should == {"usd" => "1,2,3"}
  end

  describe "frequency options" do
    it "knows if it only allows one-off payments" do
      dm = FactoryGirl.create(:donation_module, :frequency_options => {'one_off' => 'default', 'weekly' => 'hidden'})
      dm.only_allow_one_off_payment?.should == true
      dm.frequency_options['weekly'] = 'optional'
      dm.only_allow_one_off_payment?.should == false
    end

    it "constructs a list of available frequencies suitable for use as dropdown options" do
      dm = FactoryGirl.create(:donation_module, :frequency_options => {'one_off' => 'default', 'weekly' => 'hidden', 'monthly' => 'optional'})
      dm.available_frequencies_for_select.should == [ ['Donate Once', 'one_off'], ['Donate Monthly', 'monthly'] ]
    end

    it "should set default frequency" do
      dm = FactoryGirl.create(:donation_module, :frequency_options => {'one_off' => 'default', 'monthly' => 'optional'})
      dm.default_frequency.should == :one_off
      dm.default_frequency = :monthly
      dm.default_frequency.should == :monthly
    end

    it "should set frequency option to optional when un-defaulting" do
      available_frequencies = [["Donate Once", "one_off"], ["Donate Monthly", "monthly"]]
      dm = FactoryGirl.create(:donation_module, :frequency_options => {'one_off' => 'default', 'monthly' => 'optional', 'weekly' => 'hidden'})
      dm.default_frequency = :monthly
      dm.default_frequency.should == :monthly
      dm.default_frequency = :one_off
      dm.available_frequencies_for_select.should == available_frequencies

      dm.default_frequency = :weekly
      dm.default_frequency.should == :weekly
      dm.available_frequencies_for_select.should == available_frequencies << ['Donate Weekly', 'weekly']
      dm.default_frequency = :one_off
      dm.available_frequencies_for_select.should == available_frequencies
    end

    it "should make frequency optional when suggested amounts and default currency are set" do
      dm = FactoryGirl.create(:donation_module, 
                              :frequency_options => {'one_off' => 'default', 'monthly' => 'hidden', 'weekly' => 'hidden'}, 
                              :suggested_amounts => { 'usd' => '1,2,3', 'eur' => '1,2,3', 'brl' => '1,2,3' },
                              :default_currency => 'usd',
                              :default_amount => {'usd' => '1'})

      dm.available_frequencies_for_select.should == [["Donate Once", "one_off"]]

      dm.recurring_suggested_amounts = {'monthly' => {'usd' => '4,5,6', 'eur' => '4,5,6', 'brl' => '4,5,6'} }
      dm.recurring_default_amount = {'eur' => '4'}
      dm.recurring_default_currency = 'eur'
      dm.save

      dm.available_frequencies_for_select.should == [["Donate Once", "one_off"], ["Donate Monthly", "monthly"]]      
    end
  end

  describe "taking an action" do
    before(:each) do
      @user = FactoryGirl.create(:user, :email => 'noone@example.com')
      @ask = FactoryGirl.create(:donation_module)
      @page = FactoryGirl.create(:action_page)
      @email = FactoryGirl.create(:email)
    end

    it "should allow multiple donations from a single user" do
      lambda { 3.times { @ask.take_action(@user, @page) } }.should_not raise_error(DuplicateActionTakenError)
    end

    it "should create the donation with the correct values" do
      action_info = { :confirmed => true, :frequency => 'one_off', :currency => 'USD', :amount => '100', :payment_method => 'credit_card', :email => @email, :order_id => '111111', :transaction_id => '222222' }
      donation = @ask.take_action(@user, action_info, @page)

      donation.content_module.should == @ask
      donation.action_page.should == @page
      donation.user.should == @user
      donation.frequency.should == :one_off
      donation.currency.should == 'USD'
      donation.amount_in_cents.should == 100
      donation.payment_method.should == :credit_card
      donation.email.should == @email
      donation.order_id.should == '111111'
      donation.transaction_id.should == '222222'
    end

    it "should create an incomplete recurring donation" do
      action_info = { :payment_method => 'credit_card', :subscription_id => '222222', :frequency => 'monthly', :currency => 'USD', :confirmed => false }

      donation = @ask.take_action(@user, action_info, @page)

      donation.content_module.should == @ask
      donation.action_page.should == @page
      donation.user.should == @user
      donation.payment_method.should == :credit_card
      donation.subscription_id.should == '222222'
      donation.frequency.should == :monthly
      donation.currency.should == 'USD'
      donation.active.should be_false
    end
  end

  describe "tracking total amount raised" do
    before(:each) do
      @ask = FactoryGirl.create(:donation_module)
      @donation_101 = FactoryGirl.create(:donation, :content_module => @ask)
      @donation_215 = FactoryGirl.create(:donation, :content_module => @ask)

      @donation_101.transactions.create!(:amount_in_cents => 101, :successful => true)
      @donation_215.transactions.create!(:amount_in_cents => 215, :successful => true)
    end

    it "totals all the successful transactions" do
      @ask.amount_raised_in_cents.should == 316
    end

    it "converts cents to dollars" do
      @ask.amount_raised_in_dollars.should == 3.16
    end

    it "ignores failed transactions" do
      @donation_101.transactions.create!(:amount_in_cents => 1000, :successful => false)
      @ask.amount_raised_in_cents.should == 316
    end
  end

  describe "as json" do
    before do
      DonationModule::AVAILABLE_CURRENCIES = {
        :brl => Money::Currency.new('BRL'),
        :eur => Money::Currency.new('EUR'),
        :gbp => Money::Currency.new('GBP'),
        :usd => Money::Currency.new('USD')
      }
    end

    it "should include the currencies that have values assigned to" do
      ask = FactoryGirl.create(:donation_module)
      ask.default_currency = "usd"
      ask.suggested_amounts = {"brl" => "15,30", "eur" => "", "gbp" => "", "usd" => "10,20"}
      ask.recurring_suggested_amounts = { "brl" => "", "eur" => "1", "gbp" => "2", "usd" => "" }

      json = ask.as_json

      json["options"]["suggested_amounts"].keys.should =~ ["brl", "usd"]
      json["options"]["suggested_amounts"]["brl"].should eql "15,30"
      json["options"]["suggested_amounts"]["usd"].should eql "10,20"
      json["options"]["recurring_suggested_amounts"].keys.should =~ ["eur", "gbp"]
      json["options"]["recurring_suggested_amounts"]["eur"].should eql "1"
      json["options"]["recurring_suggested_amounts"]["gbp"].should eql "2"
    end

    it "should include the number of members who have donated to that action page" do
      page = FactoryGirl.create(:action_page)
      another_page_on_the_same_movement = FactoryGirl.create(:action_page, :action_sequence => page.action_sequence)

      donation_module = FactoryGirl.create(:donation_module, :pages => [page])
      donation_module_on_same_page = FactoryGirl.create(:donation_module, :pages => [page])
      donation_module_on_different_page = FactoryGirl.create(:donation_module, :pages => [another_page_on_the_same_movement])

      user = FactoryGirl.create(:user, :movement => page.movement)
      action_info = {:payment_method => :paypal, :amount => 1000, :currency => :usd, :frequency => :one_off, :confirmed => true}
      donation_module.take_action(user, action_info.merge(:order_id => 'order1', :transaction_id => 'transaction1'), page)
      donation_module_on_same_page.take_action(user, action_info.merge(:order_id => 'order2', :transaction_id => 'transaction2'), page)
      donation_module_on_different_page.take_action(user, action_info.merge(:order_id => 'order3', :transaction_id => 'transaction3'), another_page_on_the_same_movement)

      donation_module.as_json[:donations_made].should == 2
    end

    it "should incude the donation classification" do
      old_donation_module = FactoryGirl.create(:donation_module)
      old_donation_module.as_json[:classification].should eql "501(c)3"

      tax_deductible_donation_module = FactoryGirl.create(:tax_deductible_donation_module)
      tax_deductible_donation_module.as_json[:classification].should eql "501(c)3"

      non_tax_deductible_donation_module = FactoryGirl.create(:non_tax_deductible_donation_module)
      non_tax_deductible_donation_module.as_json[:classification].should eql "501(c)4"
    end

  end

  it_should_behave_like "content module with disabled content", :donation_module

  it "should be active by default" do
    donation_module = DonationModule.new
    donation_module.active.should be_true
  end
end
