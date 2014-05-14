require "spec_helper"

describe ListCutter::ActionTakenRule do
  it "should validate itself" do
    rule = ListCutter::ActionTakenRule.new

    rule.valid?.should be_false
    rule.errors.messages.should == {page_ids:["Please specify the page ids"]}
  end

  it "should return human readable form of conditions" do
    action_page1 = create(:action_page)
    action_page2 = create(:action_page)
    ListCutter::ActionTakenRule.new(not: false, page_ids: [action_page1.id.to_s, action_page2.id.to_s]).to_human_sql.should == "Page on which action was taken is any of these: #{action_page1.name}, #{action_page2.name}"
    ListCutter::ActionTakenRule.new(not: true, page_ids: [action_page1.id.to_s, action_page2.id.to_s]).to_human_sql.should == "Page on which action was taken is not any of these: #{action_page1.name}, #{action_page2.name}"
  end
end