require "spec_helper"

describe ListCutter::DonorRule do 
  it "should filter non-recurring donations" do
    @rule = ListCutter::DonorRule.new(frequencies: [:one_off])
    donation_one_off_1 = FactoryGirl.create(:donation, {frequency: "one_off"})
    donation_one_off_2 = FactoryGirl.create(:donation, {frequency: "one_off"})
    donation_weekly_1 = FactoryGirl.create(:donation, {frequency: "weekly", subscription_id: '111'})
    donation_weekly_2 = FactoryGirl.create(:donation, {frequency: "weekly", subscription_id: '222'})
    donation_monthly_1 = FactoryGirl.create(:donation, {frequency: "monthly", subscription_id: '333'})
      
    @rule.to_relation.should match_array([ donation_one_off_1.user, donation_one_off_2.user ])
  end

  it "should filter recurring donations" do
    @rule = ListCutter::DonorRule.new(frequencies: [:weekly, :monthly])

    donation_one_off_1 = FactoryGirl.create(:donation, {frequency: "one_off"})
    donation_one_off_2 = FactoryGirl.create(:donation, {frequency: "one_off"})
    donation_weekly_1 = FactoryGirl.create(:donation, {frequency: "weekly", subscription_id: '111'})
    donation_weekly_2 = FactoryGirl.create(:donation, {frequency: "weekly", subscription_id: '222'})
    donation_monthly_1 = FactoryGirl.create(:donation, {frequency: "monthly", subscription_id: '333'})
    
    @rule.to_relation.all.should match_array([donation_weekly_1.user, donation_weekly_2.user, donation_monthly_1.user])
  end

  it "should validate postcode" do
    rule = ListCutter::DonorRule.new

    rule.valid?.should be_false
    rule.errors.messages == {frequencies:["Please specify a frequency"]}
  end

end


