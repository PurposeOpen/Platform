require "spec_helper"

describe ListCutter::ZoneRule do
  it "should validate itself" do
    rule = ListCutter::ZoneRule.new

    rule.valid?.should be_false
    rule.errors.messages == {:country_iso=>["Please specify a zone code"]}
  end

  it "should return users who are from the specified zone" do
    Country.stub(:countries_in_zone => ["BR", "US"])
    action_page = FactoryGirl.create(:action_page)

    user1 = FactoryGirl.create(:user, :movement => action_page.movement, :country_iso => "BR")
    user2 = FactoryGirl.create(:user, :movement => action_page.movement, :country_iso => "AL")
    user3 = FactoryGirl.create(:user, :movement => action_page.movement, :country_iso => "US")
    user4 = FactoryGirl.create(:user, :movement => action_page.movement, :country_iso => "AW")

    rule = ListCutter::ZoneRule.new(:zone_code => 1, :movement => action_page.movement)
    rule.to_relation.all.should =~ [user1, user3]
  end

  it "should return human readable form of conditions" do
    ListCutter::ZoneRule.new(zone_code: 1, not: false).to_human_sql.should == "Zone is 1"
    ListCutter::ZoneRule.new(zone_code: 1, not: true).to_human_sql.should == "Zone is not 1"
  end
end