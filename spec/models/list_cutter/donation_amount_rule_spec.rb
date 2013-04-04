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

end


