require "spec_helper"

describe ListCutter::ExternalActionRule do
  before do
    @action_taken = ExternalActivityEvent::Activity::ACTION_TAKEN
    @action_created = ExternalActivityEvent::Activity::ACTION_CREATED
    @yesterday = 1.day.ago.strftime("%m/%d/%Y")
  end

  it { should validate_presence_of(:unique_action_slugs).with_message("Please specify the external action page slugs") }
  it { should validate_presence_of(:since).with_message("Please specify date") }
  it { should ensure_inclusion_of(:activity).in_array(ExternalActivityEvent::ACTIVITIES) }

  it "should ensure that since date is not in the future" do
    rule = ListCutter::ExternalActionRule.new(not: false, unique_action_slugs: ['1_controlshift_cuba'], activity: @action_taken, since: 1.day.from_now.strftime("%m/%d/%Y"))

    rule.valid?.should be_false
    rule.errors.messages.should == {:since => ["can't be in the future"]}
  end

  describe do
    let(:external_action_1){ ExternalAction.create! movement_id: @movement.id, action_slug: 'russia',  action_language_iso: 'en', source: 'controlshift' }
    let(:external_action_2){ ExternalAction.create! movement_id: @movement.id, action_slug: 'cuba',    action_language_iso: 'en', source: 'controlshift' }
    let(:external_action_3){ ExternalAction.create! movement_id: @movement.id, action_slug: 'ecuador', action_language_iso: 'en', source: 'controlshift' }
    let(:external_action_4){ ExternalAction.create! movement_id: @movement.id, action_slug: 'china',   action_language_iso: 'en', source: 'controlshift' }

    before do
      @movement = FactoryGirl.create(:movement)
      @bob, @john, @sally, @jenny = FactoryGirl.create_list(:user, 4, movement: @movement)
    end

    it "should return users that have taken action on specific external pages" do
      event_attributes = {:role => 'signer', activity: @action_taken}
      ExternalActivityEvent.create! event_attributes.merge(user_id: @bob.id,   external_action_id: external_action_1.id)
      ExternalActivityEvent.create! event_attributes.merge(user_id: @john.id,  external_action_id: external_action_2.id)
      ExternalActivityEvent.create! event_attributes.merge(user_id: @sally.id, external_action_id: external_action_3.id)
      ExternalActivityEvent.create! event_attributes.merge(user_id: @jenny.id, external_action_id: external_action_4.id, activity: @action_created, role: 'creator')

      rule = ListCutter::ExternalActionRule.new(not: false,
                                                unique_action_slugs: [external_action_2.unique_action_slug,
                                                                      external_action_3.unique_action_slug,
                                                                      external_action_4.unique_action_slug],
                                                activity: @action_taken, since: @yesterday, movement: @movement)

      rule.to_relation.all.should =~ [@john, @sally, @jenny]
    end

    describe 'action_created' do

      before do
        all_unique_action_slugs = [external_action_1.unique_action_slug,
                                   external_action_2.unique_action_slug,
                                   external_action_3.unique_action_slug,
                                   external_action_4.unique_action_slug]
        @rule_parameters = {not: false, unique_action_slugs: all_unique_action_slugs, activity: @action_created, since: @yesterday, movement: @movement}
        ExternalActivityEvent.create! user_id: @bob.id,   activity: @action_created, role: 'creator', external_action_id: external_action_1.id
        ExternalActivityEvent.create! user_id: @john.id,  activity: @action_created, role: 'creator', external_action_id: external_action_2.id
        ExternalActivityEvent.create! user_id: @sally.id, activity: @action_created, role: 'creator', external_action_id: external_action_3.id
        ExternalActivityEvent.create! user_id: @jenny.id, activity: @action_taken,   role: 'signer',  external_action_id: external_action_4.id
      end

      it "should return users that have created external actions for the specified sources" do
        rule = ListCutter::ExternalActionRule.new(@rule_parameters)
        rule.to_relation.all.should =~ [@bob, @john, @sally]
      end

      it "should return users that have created external actions within a timeframe" do
        ExternalActivityEvent.find_by_user_id(@bob.id).update_attribute(:created_at, 3.days.ago)

        rule = ListCutter::ExternalActionRule.new(@rule_parameters)

        rule.to_relation.all.should =~ [@john, @sally]
      end

    end

  end

  describe "#to_human_sql" do

    it "should return rule conditions in human readable form" do
      unique_action_slugs = ['1_controlshift_cuba', '1_controlshift_ecuador']

      ListCutter::ExternalActionRule.new(not: false, unique_action_slugs: unique_action_slugs, activity: @action_taken, since: @yesterday).to_human_sql.should ==
          "External action taken is any of the following since #{@yesterday}: [\"1_controlshift_cuba\", \"1_controlshift_ecuador\"]"

      ListCutter::ExternalActionRule.new(not: true, unique_action_slugs: unique_action_slugs, activity: @action_created, since: @yesterday).to_human_sql.should ==
          "External action created is not any of the following since #{@yesterday}: [\"1_controlshift_cuba\", \"1_controlshift_ecuador\"]"
    end

    it "should truncate action slugs list when it's very long" do
      slugs = *(1..30).map {|i| i.to_s}

      ListCutter::ExternalActionRule.new(not: false, unique_action_slugs: slugs, activity: @action_taken, since: @yesterday).to_human_sql.should ==
          "External action taken is any of the following since #{@yesterday}: 30 actions (too many to list)"
    end

  end

end
