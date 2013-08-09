require 'spec_helper'

describe Api::ActivitiesController do
  before(:each) do
    @page = FactoryGirl.create :action_page
    @movement = @page.movement
    @language = @movement.languages.first
    @petition_module = FactoryGirl.create :petition_module, :pages => [@page], :language => @language
    @page.content_modules << @petition_module

    @join_action_sequence = FactoryGirl.create(:published_action_sequence, :campaign => @page.action_sequence.campaign, :name => "Welcome")
    @join_page = FactoryGirl.create :action_page, :name => 'join', :action_sequence => @join_action_sequence
    @join_module = FactoryGirl.create(:join_module, :pages => [@join_page], :language => @language)
    @join_page.content_modules << @join_module
  end

  def user_that_joined_through_the_homepage
    FactoryGirl.create(:brazilian_dude, :movement => @movement, :language => @language).tap do |user|
      user.subscribe_through_homepage!
    end
  end

  def user_that_joined_through_the_join_page
    FactoryGirl.create(:brazilian_chick, :movement => @movement, :language => @language) do |user|
      user.take_action_on!(@join_page)
    end
  end

  def user_that_has_taken_an_action_on_page
    FactoryGirl.create(:aussie, :movement => @movement, :language => @language) do |user|
      user.take_action_on!(@page, :comment => "I dig this!")
    end
  end

  context 'caching' do
    it 'should cache action with request path', :caching => true do
      load "app/controllers/api/activities_controller.rb"
      Rails.cache.clear

      UserActivityEvent.should_receive(:load_feed).once.and_return([])

      get :show, :locale => :en, :movement_id => @movement.slug, :format => "json", :type => "comments"

      get :show, :locale => :en, :movement_id => @movement.slug, :format => "json"
    end
  end

  describe "#show" do
    it 'should filter out activities with profane names' do
      profane_user = FactoryGirl.create(:user_with_profane_name, :movement => @movement, :language => @language)
      profane_user.take_action_on!(@page)

      get :show, :locale => :en, :movement_id => @movement.id, :module_id => @petition_module.id, :format => "json"

      json = ActiveSupport::JSON.decode(response.body)
      json.count.should == 0
    end

    context 'module id is provided,' do
      before do
        @user = user_that_has_taken_an_action_on_page
        @another_user = FactoryGirl.build(:user, :first_name => "Paul", :last_name => "Rabbit", :movement => @movement, :language => @language)
        @another_user.take_action_on!(@page)

        @first_activity_event = UserActivityEvent.where(:movement_id => @movement.id,
                                                        :content_module_id => @petition_module.id, :user_id => @user.id,
                                                        :activity => UserActivityEvent::Activity::ACTION_TAKEN).first

        @another_activity_event = UserActivityEvent.where(:movement_id => @movement.id,
                                                          :content_module_id => @petition_module.id, :user_id => @another_user.id,
                                                          :activity => UserActivityEvent::Activity::ACTION_TAKEN).first
      end

      context 'type is activity,' do
        it 'should return all action-taken user activity events for the module' do
          get :show, :locale => :en, :movement_id => @movement.id, :module_id => @petition_module.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 2
          user_activity_event_ids = json.collect { |uae| uae["id"] }
          user_activity_event_ids.should =~ [@first_activity_event.id, @another_activity_event.id]
        end
      end

      context 'type is comments,' do
        it 'should return all action taken user activity events for the module that have comments in any language' do
          portuguese = FactoryGirl.create :portuguese
          @movement.languages << portuguese
          portuguese_petition_module = FactoryGirl.create :petition_module, :pages => [@page], :language => portuguese
          portuguese_user = FactoryGirl.build(:user, :first_name => "Manoel", :last_name => "Silva", :movement => @movement, :language => portuguese)
          portuguese_user.take_action_on!(@page, :comment => "Gostei muito!")

          get :show, :locale => :en, :movement_id => @movement.id, :module_id => portuguese_petition_module.id, :type => "comments", :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 2
          json.last["comment"].should eql "Gostei muito!"
          json.first["comment"].should eql "I dig this!"
        end

        it 'should filter out activities with profane comments' do
          @user.take_action_on!(@page, :comment => 'Mierda!!')

          get :show, :locale => :en, :movement_id => @movement.id, :module_id => @petition_module.id,
              :type => 'comments', :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 1
        end
      end

      context 'subscribed events in activity feed is enabled,' do
        it 'should not include subscribed events' do
          @movement.update_attribute(:subscription_feed_enabled, true)

          get :show, :locale => :en, :movement_id => @movement.id, :module_id => @petition_module.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should eql 2
          ids = json.collect { |uae| uae["id"] }
          ids.should =~ [@first_activity_event.id, @another_activity_event.id]
        end
      end
    end

    context 'module id is not provided,' do
      context 'subscribed events in activity feed is enabled,' do
        before do
          @movement.update_attribute(:subscription_feed_enabled, true)
        end

        it "should render the most recent :subscribed events" do
          (UserActivityEvent::DEFAULT_EVENT_LIMIT + 1).times do |i|
            user = FactoryGirl.create :user, :email => "member#{i}@example.com", :first_name => "John", :last_name => "Doe", :movement => @movement, :language => @language
            user.take_action_on!(@join_page)
          end

          last_subscription = UserActivityEvent.where(:activity => UserActivityEvent::Activity::SUBSCRIBED).order("id desc").first
          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)

          json.count.should == UserActivityEvent::DEFAULT_EVENT_LIMIT
          json.last["id"].should == last_subscription.id
          json.last["html"].should == last_subscription.public_stream_html
          json.last["timestamp"].should == last_subscription.created_at.httpdate
        end

        context 'user joins via action page,' do
          it "should filter out subscribed events that have a matching action_taken event" do
            user = user_that_joined_through_the_homepage
            another_user = user_that_has_taken_an_action_on_page

            subscribed_event_from_hp = UserActivityEvent.where(:user_id => user.id, :movement_id => @movement.id,
                                                               :activity => UserActivityEvent::Activity::SUBSCRIBED).first
            action_taken_event = UserActivityEvent.where(:user_id => another_user.id, :movement_id => @movement.id,
                                                         :activity => UserActivityEvent::Activity::ACTION_TAKEN).first

            get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

            json = ActiveSupport::JSON.decode(response.body)
            json.count.should == 2
            user_activity_event_ids = json.collect { |uae| uae["id"] }
            user_activity_event_ids.should =~ [subscribed_event_from_hp.id, action_taken_event.id]
          end

          it "should not filter out actions with profane comments if comment parameter is not present" do
            user = FactoryGirl.create(:user, :first_name => 'not', :last_name => 'profane',
                                      :movement => @movement, :language => @language)
            user.take_action_on!(@page, :comment => 'Mierda!!')

            get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

            json = ActiveSupport::JSON.decode(response.body)
            json.count.should == 1
          end
        end

        context 'user joins via join page' do
          it "should include subscribed events created via join modules" do
            user = user_that_joined_through_the_homepage
            another_user = user_that_joined_through_the_join_page

            subscribed_event = UserActivityEvent.where(:user_id => user.id, :movement_id => @movement.id,
                                                       :activity => UserActivityEvent::Activity::SUBSCRIBED).first
            another_user_subscribed_event = UserActivityEvent.where(:user_id => another_user.id,
                                                                    :movement_id => @movement.id, :activity => UserActivityEvent::Activity::SUBSCRIBED).first

            get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

            json = ActiveSupport::JSON.decode(response.body)
            json.count.should == 2
            user_activity_event_ids = json.collect { |uae| uae["id"] }
            user_activity_event_ids.should =~ [subscribed_event.id, another_user_subscribed_event.id]
          end
        end

        context "user joins through the join page and later takes an action" do
          it "should show both events on the activity feed" do
            user = user_that_joined_through_the_join_page
            user.take_action_on!(@page)

            get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

            json = ActiveSupport::JSON.decode(response.body)
            json.count.should == 2
            json[0]["html"].should include "<span class=\"name\">#{user.first_name}</span>"
            json[1]["html"].should include "<span class=\"name\">#{user.first_name}</span>"
          end
        end

        context "user takes an action and later joins through the join page" do
          it "should show only the action_taken event on the activity feed" do
            user = user_that_has_taken_an_action_on_page
            user.take_action_on!(@join_page)

            get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

            json = ActiveSupport::JSON.decode(response.body)
            json.count.should == 1
            json[0]["html"].should include "<span class=\"name\">#{user.first_name}</span>"
          end
        end

        context "user takes an action and later joins through the homepage" do
          it "should show only the action_taken event on the activity feed" do
            user = user_that_has_taken_an_action_on_page
            user.subscribe_through_homepage!

            get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

            json = ActiveSupport::JSON.decode(response.body)
            json.count.should == 1
            json[0]["html"].should include "<span class=\"name\">#{user.first_name}</span>"
          end
        end

        it "should not include anonymous users when querying for subscribed events" do
          user1 = user_that_joined_through_the_homepage
          user2 = user_that_joined_through_the_join_page
          user3 = user_that_has_taken_an_action_on_page

          anonymous_user = FactoryGirl.create(:user, :email => "anonymous@example.com", :movement => @movement,
                                              :first_name => nil, :last_name => nil, :country_iso => nil, :postcode => nil, :is_member => true)
          anonymous_user.subscribe_through_homepage!

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 3
          htmls = json.collect { |uae| uae["html"] }
          htmls =~ [
              "<span class=\"name\">#{user1.first_name}</span> joined the movement.",
              "<span class=\"name\">#{user2.first_name}</span> joined the movement.",
              "<span class=\"name\">#{user3.first_name}</span> added their signature to"
          ]
        end

        it 'should not list actions taken on unpublished pages' do
          user = user_that_has_taken_an_action_on_page
          @page.action_sequence.update_attribute(:published, false)

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 0
        end

        it 'should not list the actions taken on a page that is disabled for the requested language' do
          user = user_that_has_taken_an_action_on_page
          another_user = user_that_joined_through_the_homepage
          action_sequence = @page.action_sequence
          action_sequence.enabled_languages = []
          action_sequence.save!

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 1
        end
      end

      context 'subscribed events in activity feed is disabled,' do
        before do
          @movement.update_attribute(:subscription_feed_enabled, false)
        end

        it 'should not render the most recent :subscribed events' do
          user = user_that_joined_through_the_homepage
          another_user = user_that_has_taken_an_action_on_page

          subscribed_event = UserActivityEvent.where(:user_id => user.id, :movement_id => @movement.id,
                                                     :activity => UserActivityEvent::Activity::SUBSCRIBED).first
          action_taken_event = UserActivityEvent.where(:user_id => another_user.id,
                                                       :movement_id => @movement.id, :activity => UserActivityEvent::Activity::ACTION_TAKEN).first

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 1
          json.first["id"].should eql action_taken_event.id
        end

        it 'should not list actions taken on unpublished pages' do
          user = user_that_has_taken_an_action_on_page
          @page.action_sequence.update_attribute(:published, false)

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 0
        end

        it 'should not list the actions taken on a page that is disabled for the requested language' do
          user = user_that_has_taken_an_action_on_page
          action_sequence = @page.action_sequence
          action_sequence.enabled_languages = []
          action_sequence.save!

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"

          json = ActiveSupport::JSON.decode(response.body)
          json.count.should == 0
        end
      end

      context 'setting the expires header' do
        before do 
          Api::ActivitiesController.activity_feed_refresh_frequency = 5
        end

        it 'should be set to the correct five-second interval after now if there are no events' do
          Time.stub(:now).and_return Time.parse "17:15:42"
          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"
          response.headers['Expires'].should == Time.parse("17:15:45").httpdate
        end

        it 'should use the most recent user activity event item if there is one available' do
          user = user_that_has_taken_an_action_on_page
          action_taken_event = UserActivityEvent.where(:user_id => user.id, :movement_id => @movement.id,
                                                       :activity => UserActivityEvent::Activity::ACTION_TAKEN).first
          action_taken_event.update_attribute :created_at, Time.parse("17:15:55")

          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"
          response.headers['Expires'].should == Time.parse("17:16:00").httpdate
        end

        it 'should pick the next highest interval number on the cusp' do
          Time.stub(:now).and_return Time.parse "17:15:00"
          get :show, :locale => :en, :movement_id => @movement.id, :format => "json"
          response.headers['Expires'].should == Time.parse("17:15:05").httpdate
        end
      end
    end
  end
end
