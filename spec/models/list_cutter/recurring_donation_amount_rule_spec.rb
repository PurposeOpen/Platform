require "spec_helper"

describe ListCutter::RecurringDonationAmountRule do
  it "should return recurring donations greater than the specified amount" do
    filter = {amount: 10, operator: "more_than"}
    @rule = ListCutter::RecurringDonationAmountRule.new(filter)

    one_off_1 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 100})
    one_off_2 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 1})
    monthly_1 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 20, :subscription_amount => 20, :subscription_id => "24768374264"})
    monthly_2 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 100, :subscription_amount => 1, :subscription_id => "98798789789"})

    @rule.to_relation.all.should =~ [monthly_1.user]
    @rule.to_relation.all.should_not =~ [one_off_1.user, one_off_2.user, monthly_2.user]
  end

  it "should return recurring donations smaller than the specified amount" do
    filter = {amount: 10, operator: "less_than"}
    @rule = ListCutter::RecurringDonationAmountRule.new(filter)

    one_off_1 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 100})
    one_off_2 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 1})
    monthly_1 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 20, :subscription_amount => 20, :subscription_id => "24768374264"})
    monthly_2 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 100, :subscription_amount => 1, :subscription_id => "98798789789"})

    @rule.to_relation.all.should =~ [monthly_2.user]
    @rule.to_relation.all.should_not =~ [one_off_1.user, one_off_2.user, monthly_1.user]
  end

  it "should return recurring donations equal to the specified amount" do
    filter = {amount: 20, operator: "equal_to"}
    @rule = ListCutter::RecurringDonationAmountRule.new(filter)

    one_off_1 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 100})
    one_off_2 = FactoryGirl.create(:donation, {:frequency => "one_off", :amount_in_cents => 1})
    monthly_1 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 20, :subscription_amount => 20, :subscription_id => "24768374264"})
    monthly_2 = FactoryGirl.create(:donation, {:frequency => "monthly", :amount_in_cents => 100, :subscription_amount => 1, :subscription_id => "98798789789"})

    @rule.to_relation.all.should =~ [monthly_1.user]
    @rule.to_relation.all.should_not =~ [one_off_1.user, one_off_2.user, monthly_2.user]
  end

  describe "amount_in_dollars" do
    it "should translate cents into dollars" do
      filter = {amount: 150, operator: "less_than"}
      rule = ListCutter::RecurringDonationAmountRule.new(filter)
      rule.amount_in_dollars.should == 1.5
    end

    it "should return 0 amount_in_dollars if amount attribute is not set" do
      rule = ListCutter::RecurringDonationAmountRule.new
      rule.amount = nil
      rule.amount_in_dollars.should == 0.0
    end

    it "should translate dollars into cents" do
      rule = ListCutter::RecurringDonationAmountRule.new
      rule.amount_in_dollars = 1.5
      rule.amount.should == 150
    end

    it "should set amount from amount_in_dollars param on initialization" do
      filter = {amount_in_dollars: 15.5, operator: "less_than"}
      rule = ListCutter::RecurringDonationAmountRule.new(filter)

      rule.amount_in_dollars.should == 15.5
      rule.amount.should == 1550
    end

    it "should convert amount_in_dollars from string" do
      filter = {amount_in_dollars: "15.5", operator: "less_than"}
      rule = ListCutter::RecurringDonationAmountRule.new(filter)

      rule.amount_in_dollars.should == 15.5
      rule.amount.should == 1550
      rule.amount_in_dollars = "11.1"
      rule.amount_in_dollars.should == 11.1
      rule.amount.should == 1110
    end
  end
end
