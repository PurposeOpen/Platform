require 'spec_helper'

describe ListCutter::MostRecentDonationsRule do
  before :each do
    @movement = FactoryGirl.create(:movement)
    @other_movement = FactoryGirl.create(:movement)

    @user = FactoryGirl.create(:english_user, :movement => @movement)
    @other_user = FactoryGirl.create(:leo, :movement => @other_movement)

    @donation = FactoryGirl.create(:donation, :active => true, :user => @user, :created_at => DateTime.new(2014,1,1))
    @donation_last_year = FactoryGirl.create(:donation, :active => true, :user => @user,  :created_at => DateTime.new(2013,12,31))
    @donation_other_user = FactoryGirl.create(:donation, :active => true, :user => @other_user, :created_at => DateTime.new(2014,1,1))
  end

  it "should return the user with the donation on the provided date" do
    donation_date = "1/1/2014"
    rule = ListCutter::MostRecentDonationsRule.new(:donation_date => donation_date, :operator => "on", :movement => @movement)
    rule.to_relation.all.should =~ [ @user ]
    rule.to_relation.all.should_not =~ [ @other_user ]
  end

  it "should return the user with the donation from before the provided date" do
    donation_date = "1/2/2014"
    rule = ListCutter::MostRecentDonationsRule.new(:donation_date => donation_date, :operator => "before", :movement => @movement)
    rule.to_relation.all.should =~ [ @user ]
    rule.to_relation.all.should_not =~ [ @other_user ]
  end

  it "should return the user with the donation from after the provided date" do
    donation_date = "12/30/2013"
    rule = ListCutter::MostRecentDonationsRule.new(:donation_date => donation_date, :operator => "after", :movement => @movement)
    rule.to_relation.all.should =~ [ @user ]
    rule.to_relation.all.should_not =~ [ @other_user ]
  end

  it "should return no users before the provided date" do
    donation_date = "12/30/2012"
    rule = ListCutter::MostRecentDonationsRule.new(:donation_date => donation_date, :operator => "before", :movement => @movement)
    rule.to_relation.all.should =~ []
    rule.to_relation.all.should_not =~ [ @user, @other_user ]
  end
end
