require 'spec_helper'

describe ListCutter::RecurringDonationsRule do
  before :each do
    @movement = FactoryGirl.create(:movement)
    @other_movement = FactoryGirl.create(:movement)

    @user = FactoryGirl.create(:english_user, :movement => @movement)
    @other_user = FactoryGirl.create(:leo, :movement => @other_movement)

    FactoryGirl.create(:donation, :active => true, :user => @user)
    FactoryGirl.create(:donation, :active => false, :user => @user)
    FactoryGirl.create(:donation, :active => false, :user => @other_user)
  end

  it "should return the user with the active donation for the specific movement" do
    rule = ListCutter::RecurringDonationsRule.new(:status => '1', :movement => @movement)
    rule.to_relation.all.should =~ [ @user ]
    rule.to_relation.all.should_not =~ [ @other_user ]
  end

  it "should return the user with the inactive donation for the specific movement" do
    rule = ListCutter::RecurringDonationsRule.new(:status => '0', :movement => @movement)
    rule.to_relation.all.should =~ [ @user ]
    rule.to_relation.all.should_not =~ [ @other_user ]
  end
end
