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

      ExternalActivityEvent.create! event_attributes.merge(:user_id => @bob.id,     :action_slug => 'russia',  :activity => action_created, :source => 'controlshift',  :role => 'creator')
      ExternalActivityEvent.create! event_attributes.merge(:user_id => @john.id,    :action_slug => 'cuba',    :activity => action_created, :source => 'controloption', :role => 'creator')
      ExternalActivityEvent.create! event_attributes.merge(:user_id => @sally.id,   :action_slug => 'ecuador', :activity => action_created, :source => 'disneyland',    :role => 'creator')
      ExternalActivityEvent.create! event_attributes.merge(:user_id => @signer.id,  :action_slug => 'china',   :activity => action_taken,   :source => 'controlshift',  :role => 'signer')
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