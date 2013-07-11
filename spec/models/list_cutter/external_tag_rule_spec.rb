require "spec_helper"

describe ListCutter::ExternalTagRule do
  let(:movement)     { FactoryGirl.create(:movement) }
  let(:external_tag) { FactoryGirl.create :external_tag, name: "Cuba", movement: movement }
  let(:user1)        { FactoryGirl.create :user }
  subject            { ListCutter::ExternalTagRule.new names: [external_tag.name], movement: movement }
  
  context "when nobody taken an action for the tag" do
    its(:to_relation) { should be_empty }
  end

  context "when somebody taken an action for the tag" do
    let(:external_action) { FactoryGirl.create :external_action, external_tags: [external_tag]}
    before                { FactoryGirl.create :external_activity_event, external_action: external_action, user: user1 }
    its(:to_relation)     { should be_== [user1] }

    context "when somebody taken an action for the tag and somebody else don't" do
      let(:external_action) { FactoryGirl.create :external_action, external_tags: [external_tag]}
      let(:user2)           { FactoryGirl.create :user }
      before                { FactoryGirl.create :external_activity_event, external_action: external_action, user: user1 }
      before                { FactoryGirl.create :external_activity_event, user: user2 }
      its(:to_relation)     { should_not include user2 }
    end
  end
end
