require "spec_helper"

describe ListCutter::CampaignRule do
  it "should validate itself" do
    rule = ListCutter::CampaignRule.new

    rule.valid?.should be_false
    rule.errors.messages.should == {campaigns:["Please select one or more campaigns"]}
  end

  it "should return users who have taken action on a campaign" do
    movement = FactoryGirl.create(:movement)

    campaign1 = FactoryGirl.create(:campaign, movement: movement)
    action_sequence1 = FactoryGirl.create(:action_sequence, campaign: campaign1)
    action_page1 = FactoryGirl.create(:action_page, action_sequence: action_sequence1)

    campaign2 = FactoryGirl.create(:campaign, movement: movement)
    action_sequence2 = FactoryGirl.create(:action_sequence, campaign: campaign2)
    action_page2 = FactoryGirl.create(:action_page, action_sequence: action_sequence2)

    user1 = FactoryGirl.create(:user, movement: movement)
    user2 = FactoryGirl.create(:user, movement: movement)
    user3 = FactoryGirl.create(:user, movement: movement)

    FactoryGirl.create(:action_taken_activity, user: user1, page: action_page1, campaign: campaign1, movement: movement)
    FactoryGirl.create(:action_taken_activity, user: user1, page: action_page2, campaign: campaign2, movement: movement)
    FactoryGirl.create(:action_taken_activity, user: user2, page: action_page1, campaign: campaign1, movement: movement)
    FactoryGirl.create(:subscribed_activity, user: user3, page: action_page1, campaign: campaign1, movement: movement)

    rule = ListCutter::CampaignRule.new(campaigns: [campaign2.id], movement: movement)
    rule.to_relation.all.should == [user1]
  end

  it "should return human readable form of conditions" do
    campaign1 = create(:campaign, name: "Campaign1")
    campaign2 = create(:campaign, name: "Campaign2")
    ListCutter::CampaignRule.new(not: false, campaigns: [campaign1.id, campaign2.id]).to_human_sql.should == "Campaign is any of these: Campaign1, Campaign2"
    ListCutter::CampaignRule.new(not: true, campaigns: [campaign1.id, campaign2.id]).to_human_sql.should == "Campaign is not any of these: Campaign1, Campaign2"
  end

end
