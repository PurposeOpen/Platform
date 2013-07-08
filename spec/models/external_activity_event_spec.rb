require 'spec_helper'

describe ExternalActivityEvent do

    it { should validate_presence_of :user_id }
    it { should validate_presence_of :role }
    it { should ensure_inclusion_of(:activity).in_array(ExternalActivityEvent::ACTIVITIES) }

    it 'should create an action_taken event after creating an action_created event' do
      action_created = ExternalActivityEvent::Activity::ACTION_CREATED
      action_taken = ExternalActivityEvent::Activity::ACTION_TAKEN

      event = FactoryGirl.create(:external_activity_event, :activity => action_created, :role => 'creator')

      action_created_events, action_taken_events = ExternalActivityEvent.all.partition { |event| event.activity == action_created }
      action_created_events.should_not be_blank
      action_taken_events.should_not be_blank

      attributes_for_comparison = ExternalActivityEvent.accessible_attributes.to_a
      saved_action_taken_event_attributes = action_taken_events.first.attributes.slice(*attributes_for_comparison)
      expected_action_taken_event_attributes = event.attributes.slice(*attributes_for_comparison).merge('activity' => action_taken)
      
      saved_action_taken_event_attributes.should == expected_action_taken_event_attributes
    end

end
