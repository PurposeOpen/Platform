require "spec_helper"

describe ListCutter::ExternalActionCreatedRule do

  it { should validate_presence_of(:sources).with_message("Please specify sources") }
  it { should validate_presence_of(:since).with_message("Please specify date") }

  it "should ensure that since date is not in the future" do
    rule = ListCutter::ExternalActionCreatedRule.new(:sources => ['controlshift'], :since => 1.day.from_now.strftime("%m/%d/%Y"))

    rule.valid?.should be_false
    rule.errors.messages.should == {:since => ["can't be in the future"]}
  end

  describe do

    before do
      @movement = FactoryGirl.create(:movement)
      @bob, @john, @sally, @signer = FactoryGirl.create_list(:user, 4, :movement => @movement)
      action_taken = ExternalActivityEvent::Activity::ACTION_TAKEN
      action_created = ExternalActivityEvent::Activity::ACTION_CREATED
      
      event_attributes = {:movement_id => @movement.id, :action_language_iso => 'en'}

      external_action_1 = ExternalAction.create! event_attributes.merge(:action_slug => 'russia',  :source => 'controlshift',   :unique_action_slug => 'russia')
      external_action_2 = ExternalAction.create! event_attributes.merge(:action_slug => 'cuba',    :source => 'controloption',  :unique_action_slug => 'cuba')
      external_action_3 = ExternalAction.create! event_attributes.merge(:action_slug => 'ecuador', :source => 'disneyland',     :unique_action_slug => 'ecuador')
      external_action_4 = ExternalAction.create! event_attributes.merge(:action_slug => 'china',   :source => 'controlshift',   :unique_action_slug => 'china')
      ExternalActivityEvent.create! user_id: @bob.id,   activity: action_created,  role: "signer",  external_action_id: external_action_1.id
      ExternalActivityEvent.create! user_id: @john.id,  activity: action_created,  role: "signer",  external_action_id: external_action_2.id
    end

    it "should return users that have created external actions for the specified sources" do
      rule = ListCutter::ExternalActionCreatedRule.new(:not => false, :sources => ['controlshift', 'controloption'], :since => 1.day.ago.strftime("%m/%d/%Y"), :movement => @movement)
      rule.to_relation.all.should =~ [@bob, @john]
    end

    it "should return users that have created external actions within a timeframe" do
      ExternalActivityEvent.find_by_user_id(@bob.id).update_attribute(:created_at, 3.days.ago)
      rule = ListCutter::ExternalActionCreatedRule.new(:not => false, :sources => ['controlshift', 'controloption'], :since => 1.day.ago.strftime("%m/%d/%Y"), :movement => @movement)
      rule.to_relation.all.should =~ [@john]
    end

  end

  it "should return rule conditions in human readable form" do
    sources = ['controlshift', 'controloption']
    date = 1.day.ago.strftime("%m/%d/%Y")

    ListCutter::ExternalActionCreatedRule.new(:not => false, :sources => sources, :since => date).to_human_sql.should ==
        "Created an action via any of the following sources since #{date}: [\"controlshift\", \"controloption\"]"

    ListCutter::ExternalActionCreatedRule.new(:not => true, :sources => sources, :since => date).to_human_sql.should ==
        "Did not create an action via any of the following sources since #{date}: [\"controlshift\", \"controloption\"]"
  end

end
