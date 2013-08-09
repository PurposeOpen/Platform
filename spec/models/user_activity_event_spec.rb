# encoding: utf-8
# == Schema Information
#
# Table name: user_activity_events
#
#  id                       :integer          not null, primary key
#  user_id                  :integer          not null
#  activity                 :string(64)       not null
#  campaign_id              :integer
#  action_sequence_id       :integer
#  page_id                  :integer
#  content_module_id        :integer
#  content_module_type      :string(64)
#  user_response_id         :integer
#  user_response_type       :string(64)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  email_id                 :integer
#  push_id                  :integer
#  get_together_event_id    :integer
#  movement_id              :integer
#  comment                  :string(255)
#  comment_safe             :boolean
#

require "spec_helper"

describe UserActivityEvent do
  before(:each) do
    @join_page = FactoryGirl.create(:action_page, :name => "Join")
    @join_module = FactoryGirl.create(:join_module, :pages => [@join_page])
    @join_page.content_modules << @join_module

    @user = FactoryGirl.create(:user, :movement => @join_page.movement)

    @petition_module = FactoryGirl.create(:petition_module, :public_activity_stream_template => "Someone signed!")
    @signature = FactoryGirl.create(:petition_signature, :user => @user, :content_module => @petition_module)
    @page = FactoryGirl.create(:action_page, :action_sequence => @join_page.action_sequence)
    @email = FactoryGirl.create(:email)
  end

  describe 'json format' do
    it 'should return time ago in words for created at in the locale language' do
      event = UserActivityEvent.subscribed!(@user)
      I18n.locale = :en
      json_object = JSON.parse(event.to_json)
      json_object["timestamp_in_words"].should =~ /ago/
    end

    it 'should return country name in the locale language' do
      user = create(:user, :country_iso => 'fr', :movement => @join_page.movement)
      portuguese = create(:portuguese)
      event = UserActivityEvent.subscribed!(user)
      I18n.locale = :pt
      json_object = JSON.parse(event.to_json(:language => portuguese))
      json_object['country'].should == 'França'
      json_object['country_iso'].should == 'fr'
    end
  end

  describe "creating a subscribed event" do
    it "creates an event without signup ask/page information" do
      event = UserActivityEvent.subscribed!(@user)
      event.activity.should == :subscribed
      event.user.should == @user
      event.content_module.should == nil
      event.page.should == nil
      event.public_stream_html.should include %{<span class="name">A member</span>}
      event.movement.should == @user.movement
    end

    it "creates an event including signup ask/page information" do
      event = UserActivityEvent.subscribed!(@user, nil, @page, @petition_module)
      event.activity.should == :subscribed
      event.user.should == @user
      event.content_module.should == @petition_module
      event.content_module_type.should == "PetitionModule"
      event.page.should == @page
      event.action_sequence.should == @page.action_sequence
      event.campaign.should == @page.action_sequence.campaign
      event.public_stream_html.should include %{<span class="name">A member</span>}
      event.movement.should == @page.movement
    end
  end

  describe 'action_taken' do
    context 'page is present' do
      it "creates an action_taken event, using the page's movement" do
        event = UserActivityEvent.action_taken!(@user, @page, @petition_module, @signature, @email)
        event.activity.should == :action_taken
        event.user.should == @user
        event.user_response.should == @signature
        event.content_module.should == @petition_module
        event.content_module_type.should == "PetitionModule"
        event.page.should == @page
        event.action_sequence.should == @page.action_sequence
        event.campaign.should == @page.action_sequence.campaign
        event.public_stream_html.should == "Someone signed!"
        event.movement.should == @page.movement
      end

      it "should allow multiple identical action taken events" do
        UserActivityEvent.action_taken!(@user, @page, @petition_module, @signature, @email)
        UserActivityEvent.action_taken!(@user, @page, @petition_module, @signature, @email)

        UserActivityEvent.where(:user_id           => @user.id,
                                :page_id           => @page.id,
                                :content_module_id => @petition_module.id,
                                :user_response_id  => @signature.id,
                                :email_id          => @email.id).count.should == 2
      end
    end

    context 'page is not present and movement is blank' do
      it "creates an action_taken event, using the user's movement" do
        event = UserActivityEvent.action_taken!(@user, @page, @petition_module, @signature, @email)
        event.activity.should == :action_taken
        event.user.should == @user
        event.user_response.should == @signature
        event.content_module.should == @petition_module
        event.content_module_type.should == "PetitionModule"
        event.page.should == @page
        event.action_sequence.should == @page.action_sequence
        event.campaign.should == @page.action_sequence.campaign
        event.public_stream_html.should == "Someone signed!"
        event.movement.should == @user.movement
      end
    end
  end

  describe 'email clicked event' do
    it "creates an email clicked event and an email viewed event" do
      @email = FactoryGirl.create(:email)
      push = @email.blast.push
      UserActivityEvent.email_clicked!(@user, @email, @page)

      push.count_by_activity(:email_clicked).should eql 1
      push.count_by_activity(:email_viewed).should eql 1
    end
  end

  context 'email flagged as spam' do
    it 'creates an email spammed event' do
      @email = FactoryGirl.create(:email)
      push = @email.blast.push
      UserActivityEvent.email_spammed!(@user, @email)

      push.count_by_activity(:email_spammed).should eql 1
    end
  end

  it "creates an email viewed event" do
    @email = FactoryGirl.create(:email)
    push = @email.blast.push
    UserActivityEvent.email_viewed!(@user, @email)

    push.count_by_activity(:email_viewed).should eql 1
  end

  describe "comment filter" do
    it "should flag the comment as unsafe if it contains profanity" do
      uae = FactoryGirl.create(:action_taken_activity, :comment => 'This is a profane comment, Mierda')
      uae.comment_safe.should == false
    end
    
    it "should flag the comment as safe if it doesn't contain profanity" do
      uae = FactoryGirl.create(:action_taken_activity, :comment => 'This is not a profane comment')
      uae.comment_safe.should == true
    end

    it "should flag the comment as unsafe if it contains a URL" do
      uae_http = FactoryGirl.create(:action_taken_activity, :comment => 'http://www.example.com')
      uae_http.comment_safe.should == false

      uae_https = FactoryGirl.create(:action_taken_activity, :comment => 'https://www.example.com')
      uae_https.comment_safe.should == false

      uae_without_scheme = FactoryGirl.create(:action_taken_activity, :comment => 'www.example.com')
      uae_without_scheme.comment_safe.should == false
    end
  end

  describe "actions_taken_for_sequence" do
    it "should fetch actions taken events for sequence with user, page, action_sequence, and user language eager loaded" do
      action_sequence = create(:action_sequence)
      event1 = create(:activity, action_sequence: action_sequence)
      event2 = create(:activity, action_sequence: action_sequence)
      create(:subscribed_activity, action_sequence: action_sequence)
      create(:email_sent_activity, action_sequence: action_sequence)

      other_action_sequence = create(:action_sequence)
      create(:activity, action_sequence: other_action_sequence)

      events = UserActivityEvent.actions_taken_for_sequence(action_sequence)

      events.should == [event1, event2]
      event = events.first
      event.association(:user).should be_loaded
      event.association(:page).should be_loaded
      event.association(:action_sequence).should be_loaded
      event.user.association(:language).should be_loaded
    end
  end

  describe "#to_row" do
    it "should convert to row" do
      user = create(:user, country_iso: 'us', language: create(:language, iso_code: 'en'))
      action_sequence = create(:action_sequence)
      action_page = create(:action_page)
      activity = create(:activity, user: user, page: action_page, action_sequence: action_sequence, content_module_type: 'PetitionModule')

      activity.to_row.should == [activity.created_at, action_sequence.name, action_page.name, 'Petition',
        'EN', user.email, user.first_name, user.last_name, user.name_safe, 'US',
        user.postcode, user.mobile_number, activity.comment, activity.comment_safe]
    end

    it "should convert to row if some attributes are nil" do
      user = create(:user, country_iso: nil, language: nil)
      action_sequence = create(:action_sequence)
      action_page = create(:action_page)
      activity = create(:activity, user: user, page: action_page, action_sequence: action_sequence, content_module_type: nil)

      activity.to_row.should == [activity.created_at, action_sequence.name, action_page.name, '',
        nil, user.email, user.first_name, user.last_name, user.name_safe, nil,
        user.postcode, user.mobile_number, activity.comment, activity.comment_safe]
    end
  end
end
