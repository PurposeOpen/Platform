require "spec_helper"

describe ListCutter::ExternalActionTakenRule do

  it { should validate_presence_of(:action_slugs).with_message("Please specify the external action page slugs") }

  describe do

    before do
      @movement = FactoryGirl.create(:movement)
      @bob, @john, @sally, @creator = FactoryGirl.create_list(:user, 4, :movement => @movement)

      event_attributes = {:movement_id => @movement.id, :action_language_iso => 'en'}
      
      external_action_1 = ExternalAction.create! event_attributes.merge(:action_slug => 'russia',  :source => 'controlshift',   :unique_action_slug => 'russia')
      external_action_2 = ExternalAction.create! event_attributes.merge(:action_slug => 'cuba',    :source => 'controloption',  :unique_action_slug => 'cuba')
      external_action_3 = ExternalAction.create! event_attributes.merge(:action_slug => 'ecuador', :source => 'disneyland',     :unique_action_slug => 'ecuador')
      external_action_4 = ExternalAction.create! event_attributes.merge(:action_slug => 'china',   :source => 'controlshift',   :unique_action_slug => 'china')

      ExternalActivityEvent.create! :user_id => @bob.id,      role: 'signer',   external_action_id: external_action_1.id, :activity => ExternalActivityEvent::Activity::ACTION_TAKEN
      ExternalActivityEvent.create! :user_id => @john.id,     role: 'signer',   external_action_id: external_action_2.id, :activity => ExternalActivityEvent::Activity::ACTION_TAKEN
      ExternalActivityEvent.create! :user_id => @sally.id,    role: 'signer',   external_action_id: external_action_3.id, :activity => ExternalActivityEvent::Activity::ACTION_TAKEN
      ExternalActivityEvent.create! :user_id => @creator.id,  role: 'creator',  external_action_id: external_action_4.id, :activity => ExternalActivityEvent::Activity::ACTION_CREATED, :role => 'creator'
    end

    it "should return users that have taken action on specific external pages" do
      rule = ListCutter::ExternalActionTakenRule.new(:not => false, :action_slugs => ['cuba', 'ecuador', 'china'], :movement => @movement)
      rule.to_relation.all.should =~ [@john, @sally, @creator]
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
