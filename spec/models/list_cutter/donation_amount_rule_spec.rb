require "spec_helper"

describe ListCutter::DonationAmountRule do

  it "should filter donations greater than the specified amount" do
    filter = {amount: 10, operator: "more_than"}
    @rule = ListCutter::DonationAmountRule.new(filter)
    donation_one_off_1 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 100})
    donation_one_off_2 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 1})

    donation_monthly_1 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 10, :subscription_amount => 10, :subscription_id => "24768374264"})
    donation_monthly_2 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 1, :subscription_amount => 1, :subscription_id => "98798789789"})

    @rule.to_relation.all.should =~ [donation_one_off_1.user, donation_monthly_1.user]
  end

  it "should filter donations smaller than the specified amount" do
    filter = {amount: 10, operator: "less_than"}
    @rule = ListCutter::DonationAmountRule.new(filter)
    donation_one_off_1 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 100})
    donation_one_off_2 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 1})

    donation_monthly_1 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 20, :subscription_amount => 20, :subscription_id => "24768374264"})
    donation_monthly_2 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 100, :subscription_amount => 1, :subscription_id => "98798789789"})

    @rule.to_relation.all.should =~ [donation_one_off_2.user, donation_monthly_2.user]
  end

  describe "amount_in_dollars" do
    it "should translate cents into dollars" do
      filter = {amount: 150, operator: "less_than"}
      rule = ListCutter::DonationAmountRule.new(filter)

      rule.amount_in_dollars.should == 1.5
    end

    it "should return 0 amount_in_dollars if amount attribute is not set" do
      rule = ListCutter::DonationAmountRule.new

      rule.amount = nil

      rule.amount_in_dollars.should == 0.0
    end

    it "should translate dollars into cents" do
      rule = ListCutter::DonationAmountRule.new

      rule.amount_in_dollars = 1.5

      rule.amount.should == 150
    end

    it "should set amount from amount_in_dollars param on initialization" do
      filter = {amount_in_dollars: 15.5, operator: "less_than"}
      
      rule = ListCutter::DonationAmountRule.new(filter)

      rule.amount_in_dollars.should == 15.5
      rule.amount.should == 1550
    end

    it "should convert amount_in_dollars from string" do
      filter = {amount_in_dollars: "15.5", operator: "less_than"}
      
      rule = ListCutter::DonationAmountRule.new(filter)

      rule.amount_in_dollars.should == 15.5
      rule.amount.should == 1550

      rule.amount_in_dollars = "11.1"

      rule.amount_in_dollars.should == 11.1
      rule.amount.should == 1110
    end
  end

end


