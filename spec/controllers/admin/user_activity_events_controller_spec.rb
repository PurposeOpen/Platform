require 'spec_helper'

describe Admin::UserActivityEventsController do
  include Devise::TestHelpers # to give your spec access to helpers

  before :each do
    @movement = FactoryGirl.create(:movement, :name => 'Test Movement', :languages => [FactoryGirl.create(:english), FactoryGirl.create(:portuguese), FactoryGirl.create(:french)])
    @campaign = FactoryGirl.create(:campaign, :movement => @movement)
    # mock up an authentication in the underlying warden library
    user = FactoryGirl.create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => user, :authenticate! => user)
  end

  describe "GET 'index'" do
    it "should generate csv of all user activities for sequence" do
      action_sequence = create(:action_sequence, campaign: @campaign, name: 'Test Sequence')
      action_page = create(:action_page, action_sequence: action_sequence)
      activity1 = create(:activity, action_sequence: action_sequence, page: action_page, content_module_type: 'PetitionModule')
      activity2 = create(:activity, action_sequence: action_sequence, page: action_page, content_module_type: 'PetitionModule')
      activities = [activity1, activity2]
      UserActivityEvent.should_receive(:actions_taken_for_sequence).with(action_sequence).and_return(activities)

      get :index, :movement_id => @movement.id, :action_sequence_id => action_sequence.id

      response.should be_success

      response.header['Content-Type'].should include 'text/csv'
      response.header['Content-Disposition'].should match(/filename="test-movement-test-sequence-activities-.*?\.csv"/)
      response.body.should match(<<-CSV
#{ActivitiesReport.columns.join(',')}
#{activity1.to_row.join(',')}
#{activity2.to_row.join(',')}
      CSV
      )
    end
  end
end
