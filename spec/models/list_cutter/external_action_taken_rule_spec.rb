require "spec_helper"

describe ListCutter::ExternalActionTakenRule do

  it "should validate itself" do
    rule = ListCutter::ExternalActionTakenRule.new

    rule.valid?.should be_false
    rule.errors.messages.should == {:action_slugs => ["Please specify the external action page slugs"]}
  end

  describe do

    before do
      @movement = FactoryGirl.create(:movement)
      @bob, @john, @sally, @creator = FactoryGirl.create_list(:user, 4, :movement => @movement)

      event_attributes = {:movement_id => @movement.id, :role => 'signer', :action_language_iso => 'en', :source => 'controlshift', :activity => ExternalActivityEvent::Activity::ACTION_TAKEN}

      ExternalActivityEvent.create! event_attributes.merge(:user_id => @bob.id, :action_slug => 'russia',)
      ExternalActivityEvent.create! event_attributes.merge(:user_id => @john.id, :action_slug => 'cuba',)
      ExternalActivityEvent.create! event_attributes.merge(:user_id => @sally.id, :action_slug => 'ecuador',)
      ExternalActivityEvent.create! event_attributes.merge(:user_id => @creator.id, :action_slug => 'china', :activity => ExternalActivityEvent::Activity::ACTION_CREATED)
    end

    it "should return users that have taken action on specific external pages" do
      rule = ListCutter::ExternalActionTakenRule.new(:any_actions => false, :not => false, :action_slugs => ['cuba', 'ecuador', 'china'], :movement => @movement)

      rule.to_relation.all.should =~ [@john, @sally]
    end

  end

  it "should return rule conditions in human readable form" do
    slugs = ['cuba', 'ecuador']

    ListCutter::ExternalActionTakenRule.new(:not => false, :action_slugs => slugs).to_human_sql.should ==
        "External action taken is any of these: [\"cuba\", \"ecuador\"]"

    ListCutter::ExternalActionTakenRule.new(:not => true, :action_slugs => slugs).to_human_sql.should ==
        "External action taken is not any of these: [\"cuba\", \"ecuador\"]"
  end

end