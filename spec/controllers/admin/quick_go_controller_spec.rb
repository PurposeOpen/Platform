require 'spec_helper'

describe Admin::QuickGoController, solr: true do
  before do
    request.env['warden'] = mock(Warden, authenticate: FactoryGirl.create(:user, is_admin: true),
                                 authenticate!: FactoryGirl.create(:user, is_admin: true))
  end
  it 'should return results' do
    term = 'Awesome stuff'
    movement = create(:movement)
    campaign = create(:campaign, movement: movement, name: term)
    action_sequence = create(:action_sequence, campaign: campaign, name: term)
    action_sequence.index!
    action_page = create(:action_page, action_sequence: action_sequence, name: term)
    content_page = create(:content_page, movement: movement, name: "#{term} content page")
    push = create(:push, campaign: campaign, name: term)
    blast = create(:blast, push: push)
    email = create(:email, blast: blast, name: term)
    [campaign, action_sequence, action_page, content_page, push, email].each{|m| m.index!}

    get :index, movement_id: movement.id, term: 'awe'

    results = JSON.parse(response.body)
    results.size.should == 6
    results.find{|r| r['type'] == 'Campaign'}['path'].should == admin_movement_campaign_path(movement, campaign)
    results.find{|r| r['type'] == 'ActionSequence'}['path'].should == admin_movement_action_sequence_path(movement, action_sequence)
    results.find{|r| r['type'] == 'ActionPage'}['path'].should == edit_admin_movement_action_page_path(movement, action_page)
    results.find{|r| r['type'] == 'ContentPage'}['path'].should == edit_admin_movement_content_page_path(movement, content_page)
    results.find{|r| r['type'] == 'Push'}['path'].should == admin_movement_push_path(movement, push)
    results.find{|r| r['type'] == 'Email'}['path'].should == edit_admin_movement_email_path(movement, email)
  end
end
