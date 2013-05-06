#encoding: utf-8
require "spec_helper"

describe Api::ActionPagesController do

  before :each do
    @fields = {:first_name      => :required,
               :last_name       => :optional,
               :postcode        => :required,
               :country         => :required,
               :mobile_number   => :refresh,
               :home_number     => :hidden,
               :street_address  => :hidden,
               :suburb          => :hidden}

    @english = create(:english)
    @portuguese = create(:portuguese)

    @movement = create(:movement, :name => "All Out", :languages => [@english, @portuguese])
    @campaign = create(:campaign, :movement => @movement)
    @action_sequence = create(:published_action_sequence, :campaign => @campaign, :enabled_languages => [@english.iso_code, @portuguese.iso_code])
    @page = create(:action_page, :name => "Cool page", :action_sequence => @action_sequence, :required_user_details => @fields)
    @petition_module = create(:petition_module, :pages => [@page], :language => @english)
    create(:petition_module, :pages => [@page], :language => @portuguese)
  end

  describe 'member_fields,' do
    context 'member exists,' do
      describe 'refresh fields' do

        context 'member has not entered a field set to refresh,' do
          it "should return json with the refresh field," do
            user = create(:user, :movement_id => @movement.id)
            get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

            json = remove_callback_wrapper(response.body)
            data = ActiveSupport::JSON.decode(json)

            data['member_fields']['mobile_number'].should eql 'refresh'
          end
        end

        context 'member has entered a field set to refresh,' do
          it "should return json with the refresh field," do
            user = create(:user, :mobile_number => '6317234567')
            get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

            json = remove_callback_wrapper(response.body)
            data = ActiveSupport::JSON.decode(json)

            data['member_fields']['mobile_number'].should eql 'refresh'
          end

        end

        context "two movements have pages with the same name" do
          it 'should check the fields required on the page that belongs to the queried movement' do
            another_page_fields = {
              :first_name      => :required,
              :last_name       => :hidden,
              :postcode        => :hidden,
              :country         => :hidden,
              :mobile_number   => :hidden,
              :home_number     => :hidden,
              :street_address  => :hidden,
              :suburb          => :hidden
            }
            another_movement = create(:movement)
            another_campaign = create(:campaign, :movement => another_movement)
            another_action_sequence = create(:published_action_sequence, :campaign => another_campaign, :enabled_languages => [@english.iso_code.to_s, @portuguese.iso_code.to_s])
            another_page = create(:action_page, :name => @page.name, :action_sequence => another_action_sequence, :required_user_details => another_page_fields)
            another_petition_module = create(:petition_module, :pages => [another_page], :language => @english)

            user = create(:user, :movement_id => @movement.id)

            get :member_fields, :movement_id => another_movement.friendly_id, :id => another_page.friendly_id, :email => user.email, :callback => "callback"

            json = remove_callback_wrapper(response.body)
            data = ActiveSupport::JSON.decode(json)

            data['member_fields']['email'].should eql 'required'
            data['member_fields']['first_name'].should eql 'required'
            data['member_fields'].size.should eql 2
          end
        end

      end

      describe 'required fields' do

        it "should return json with the required field when member has not entered a required field" do
          user = create(:user, :movement_id => @movement.id)
          get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

          json = remove_callback_wrapper(response.body)
          data = ActiveSupport::JSON.decode(json)

          data['member_fields']['country'].should eql 'required'
        end

        it "should return json without the required field when member has entered a required field" do
          user = create(:user, :country_iso => 'US', :movement_id => @movement.id)
          get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

          json = remove_callback_wrapper(response.body)
          data = ActiveSupport::JSON.decode(json)

          data['member_fields'].has_key?('country').should be_false
        end

        it "should set postcode as required when the selected country is postcode-aware" do
          user = create(:user, :movement_id => @movement.id, :country_iso => 'us')
          get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

          json = remove_callback_wrapper(response.body)
          data = ActiveSupport::JSON.decode(json)

          data['member_fields']['postcode'].should eql 'required'
        end

        it "should not set postcode as required when the selected country is not postcode-aware" do
          user = create(:user, :movement_id => @movement.id, :country_iso => 'ao')
          get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

          json = remove_callback_wrapper(response.body)
          data = ActiveSupport::JSON.decode(json)

          data['member_fields'].has_key?('postcode').should be_false
        end

      end

      describe 'optional fields' do

        context 'member has not entered a field set to optional' do
          it "should return json with the optional field" do
            user = create(:user, :movement_id => @movement.id)
            get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

            json = remove_callback_wrapper(response.body)
            data = ActiveSupport::JSON.decode(json)

            data['member_fields'].has_key?('last_name').should be_true
          end
        end

        context 'member has entered a field set to optional' do
          it "should return json without the optional field" do
            user = create(:user, :last_name => 'Marley', :movement_id => @movement.id)
            get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

            json = remove_callback_wrapper(response.body)
            data = ActiveSupport::JSON.decode(json)

            data['member_fields'].has_key?('last_name').should be_false
          end
        end

      end

      describe 'country and postcode interaction,' do

        it "should take user's input country over their existing country when re-signing" do
          user = create(:user, :movement_id => @movement.id, :country_iso => 'af')
          get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :country_iso => 'us', :callback => 'callback'

          json = remove_callback_wrapper(response.body)
          data = ActiveSupport::JSON.decode(json)

          data['member_fields']['postcode'].should eql 'required'
        end

        it "should return json with refresh for country and postcode when both are set to refresh and country requires postcode" do
          user = create(:user, :movement_id => @movement.id, :country_iso => "us")

          @page.update_attribute('required_user_details', @page.required_user_details.merge(:country => :refresh, :postcode => :refresh))
          @page.save!

          get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

          json = remove_callback_wrapper(response.body)
          data = ActiveSupport::JSON.decode(json)

          data['member_fields']['country'].should eql 'refresh'
          data['member_fields']['postcode'].should eql 'refresh'
        end
      end

    end

    context 'new member,' do
      it "should return json with required, optional, and refresh fields" do
        get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => "nobody@example.com", :callback => "callback"

        json = remove_callback_wrapper(response.body)
        data = ActiveSupport::JSON.decode(json)

        data['member_fields'].should eql stringify_hash(@page.non_hidden_user_details)
      end

      it "should set postcode as required when the selected country is postcode-aware" do
        get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => 'nobody@example.com', :country_iso => 'us', :callback => "callback"

        json = remove_callback_wrapper(response.body)
        data = ActiveSupport::JSON.decode(json)

        data['member_fields']['postcode'].should eql 'required'
      end

      it "should not set postcode as required when the selected country is not postcode-aware" do
        get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => 'nobody@example.com', :country_iso => 'ao', :callback => "callback"

        json = remove_callback_wrapper(response.body)
        data = ActiveSupport::JSON.decode(json)

        data['member_fields'].has_key?('postcode').should be_false
      end
    end

    context 'new member in different movement' do
      it "should find members according to movement" do
        another_movement = create(:movement)
        user = create(:user, :movement => another_movement)

        get :member_fields, :movement_id => @movement.friendly_id, :id => @page.id, :email => user.email, :callback => "callback"

        json = remove_callback_wrapper(response.body)
        data = ActiveSupport::JSON.decode(json)
        data['member_fields'].should eql stringify_hash(@page.non_hidden_user_details)
      end
    end
  end

  describe 'show,' do
    it "should return json with the page content" do
      header_content = create(:html_module, :title => "Header", :content => "Welcome!")
      sidebar_content = create(:petition_module, :title => "Petition", :content => "Sign this petition!")
      main_content = create(:html_module, :title => "Html", :content => "You don't have JS enabled!")
      page = create(:action_page, :name => "Cool page")
      create(:header_module_link, :content_module => header_content, :page => page)
      create(:sidebar_module_link, :content_module => sidebar_content, :page => page)
      create(:main_module_link, :content_module => main_content, :page => page)
      MemberCountCalculator.init(page.action_sequence.campaign.movement, 10000)

      user = create(:user, :movement => @movement)
      email = create(:email)

      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

      get :show, :movement_id => page.action_sequence.campaign.movement.id, :id => page.id, :t => tracking_hash

      data = ActiveSupport::JSON.decode(response.body)
      data["id"].should eql page.id
      data["name"].should eql "Cool page"
      data["header_content_modules"].first["title"].should eql "Header"
      data["header_content_modules"].first["content"].should eql "Welcome!"
      data["sidebar_content_modules"].first["title"].should eql "Petition"
      data["sidebar_content_modules"].first["content"].should eql "Sign this petition!"
      data["main_content_modules"].first["title"].should eql "Html"
      data["main_content_modules"].first["content"].should eql "You don't have JS enabled!"
      data["is_join_page"].should be_false
      data["member_count"].should eql "10,000"
      response.headers['Content-Language'].should eql "en"
    end

    it "should return page content modules by specified locale" do
      english = create(:english)
      portuguese = create(:portuguese)
      movement = create(:movement, :languages => [english, portuguese])
      campaign = create(:campaign, :movement => movement)
      action_sequence = create(:published_action_sequence, :campaign => campaign)

      header_content_in_english = create(:html_module, :title => "Header", :content => "Welcome!", :language => english)
      sidebar_content_in_english = create(:petition_module, :title => "Petition", :content => "Sign this petition!", :language => english)
      header_content_in_portuguese = create(:html_module, :title => "Cabeçalho", :content => "Bem-vindo!", :language => portuguese)
      sidebar_content_in_portuguese = create(:petition_module, :title => "Petição", :content => "Assine essa petição!", :language => portuguese)
      page = create(:action_page, :name => "Cool page", :action_sequence => action_sequence)
      create(:header_module_link, :content_module => header_content_in_english, :page => page)
      create(:header_module_link, :content_module => header_content_in_portuguese, :page => page)
      create(:sidebar_module_link, :content_module => sidebar_content_in_english, :page => page)
      create(:sidebar_module_link, :content_module => sidebar_content_in_portuguese, :page => page)

      get :show, :movement_id => page.action_sequence.campaign.movement.id, :id => page.id, :locale => "pt"

      data = ActiveSupport::JSON.decode(response.body)
      data["id"].should eql page.id
      data["name"].should eql "Cool page"
      data["header_content_modules"].size.should eql 1
      data["header_content_modules"].first["title"].should eql "Cabeçalho"
      data["header_content_modules"].first["content"].should eql "Bem-vindo!"
      data["sidebar_content_modules"].size.should eql 1
      data["sidebar_content_modules"].first["title"].should eql "Petição"
      data["sidebar_content_modules"].first["content"].should eql "Assine essa petição!"
      response.headers['Content-Language'].should eql "pt"
    end

    it "should return valid json even if the page has no content modules" do
      page = create(:action_page, :name => "Cool page")
      page.action_sequence.campaign.movement.default_language = Language.find_by_iso_code("en")

      get :show, :movement_id => page.action_sequence.campaign.movement.id, :id => page.id

      data = ActiveSupport::JSON.decode(response.body)
      data["name"].should eql "Cool page"
      data["header_content_modules"].should be_empty
      data["sidebar_content_modules"].should be_empty
      data["main_content_modules"].should be_empty
      response.headers['Content-Language'].should eql "en"
    end

    it "should return Not Found status when there's no page matching the query" do
      movement = create(:movement)
      get :show, :movement_id => movement.id, :id => -1

      response.status.should eql 404
    end

    it "should only return content for pages that belong to the specified movement" do
      first_movement_page = create(:action_page, :name => "Cool page in first movement")
      second_movement_page = create(:action_page, :name => "Cool page in second movement")

      get :show, :movement_id => first_movement_page.movement.id, :id => second_movement_page.id

      first_movement_page.movement.id.should_not eql second_movement_page.movement.id
      response.status.should eql 404
    end

    it "should only return content for pages that belong to the specified movement when using friendly ids" do
      first_movement_page = create(:action_page, :name => "Cool page in first movement")
      second_movement_page = create(:action_page, :name => "Cool page in second movement")

      get :show, :movement_id => first_movement_page.movement.id, :id => "cool-page-in-second-movement"

      first_movement_page.movement.id.should_not eql second_movement_page.movement.id
      response.status.should eql 404
    end

    it "should return Not Found status when the action sequence of the given page is not published" do
      @page.action_sequence.update_attribute :published, false

      get :show, :movement_id => @page.movement.id, :id => @page.friendly_id

      response.status.should eql 404
    end

    it "should return No Acceptable Content status when the action sequence is published but there's no content for the requested language" do
      action_sequence = @page.action_sequence
      action_sequence.update_attributes :published => true
      action_sequence.enabled_languages = [@english.iso_code.to_s]
      action_sequence.save!

      get :show, :movement_id => @page.movement.id, :id => @page.friendly_id, :locale => @portuguese.iso_code

      response.status.should eql 406
      response.body.should eql "{\"error\":\"No content for content locale accepted by the client.\"}"
    end
  end

  describe "take_action" do
    it "should add new user information if it's a new user taking an action" do
      create(:autofire_email, :action_page => @page, :language => @portuguese)
      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :member_info => { :first_name => "Bob", :last_name => "Johnson", :email => "bob@johnson.com" }, :locale => "pt"

      created_user = User.find_by_email("bob@johnson.com")
      created_user.first_name.should eql "Bob"
      created_user.last_name.should eql "Johnson"
      created_user.language.should eql @portuguese
      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
    end

    it "should update user information if it's an existing user taking an action" do
      create(:autofire_email, :action_page => @page, :language => @portuguese)
      create(:user, :email => "bob@johnson.com", :first_name => "Bob", :last_name => "Johnson", :movement_id => @movement.id)

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :member_info => { :first_name => "James", :email => "bob@johnson.com" }, :locale => "pt"

      created_user = User.find_by_email("bob@johnson.com")
      created_user.first_name.should eql "James"
      created_user.last_name.should eql "Johnson"
      created_user.language.should eql @portuguese
      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
      User.find_all_by_email("bob@johnson.com").size.should eql 1
    end

    it "should create new user information if the same user is taking an action in a different movement" do
      create(:user, :movement => @movement, :email => "bob@johnson.com", :first_name => "James")

      walkfree = create(:movement, :name => "WalkFree")
      walkfree_campaign = create(:campaign, :movement => walkfree)
      walkfree_action_sequence = create(:published_action_sequence, :campaign => walkfree_campaign)
      walkfree_portuguese_petition_module = create(:petition_module, :language => @portuguese)
      walkfree_page = create(:action_page, :action_sequence => walkfree_action_sequence, :content_modules => [walkfree_portuguese_petition_module, create(:petition_module)])
      create(:autofire_email, :action_page => walkfree_page, :language => @portuguese)
      create(:email_footer, :movement => walkfree, :language => @portuguese)
      create(:autofire_email, :action_page => walkfree_page, :language => @english)
      create(:email_footer, :movement => walkfree, :language => @english)

      put :take_action, :movement_id => "walkfree", :id => walkfree_page.id, :member_info => { :first_name => "James", :email => "bob@johnson.com" }, :locale => @portuguese.iso_code

      User.find_all_by_email("bob@johnson.com").size.should eql 2
    end

    it "should respond with the next page identifier if there is one" do
      next_page = create(:action_page, action_sequence_id: @page.action_sequence_id, position: @page.position + 1, name: "thanks")
      create(:autofire_email, :action_page => @page, :language => @portuguese)

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :member_info => { :first_name => "James", :email => "bob@johnson.com" }, :locale => @portuguese.iso_code

      data = ActiveSupport::JSON.decode(response.body)
      data['next_page_identifier'].should eql "thanks"
    end

    it "should respond with the member id" do
      create(:autofire_email, :action_page => @page, :language => @portuguese)

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :member_info => { :first_name => "James", :email => "bob@johnson.com" }, :locale => @portuguese.iso_code

      data = ActiveSupport::JSON.decode(response.body)
      data['member_id'].should eql User.find_by_email("bob@johnson.com").id
    end

    it "should not respond with the next page identifier when it does not exist" do
      create(:autofire_email, :action_page => @page, :language => @portuguese)
      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :member_info => { :first_name => "James", :email => "bob@johnson.com" }, :locale => @portuguese.iso_code

      data = ActiveSupport::JSON.decode(response.body)
      data['next_page_identifier'].should be_nil
    end

    #VERSION: accepting both platform_member and member_info params keys for backwards compatibility.
    it "should support parameters passed as platform_member" do
      create(:autofire_email, :action_page => @page, :language => @portuguese)
      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :platform_member => { :first_name => "Bob", :last_name => "Johnson", :email => "bob@johnson.com" }, :locale => "pt"

      created_user = User.find_by_email("bob@johnson.com")
      created_user.first_name.should eql "Bob"
      created_user.last_name.should eql "Johnson"
      created_user.language.should eql @portuguese
      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
    end

    it "should unsubscribe existing member" do
      @movement.default_language = @portuguese
      unsubscribe_page = create(:action_page, :action_sequence => @page.action_sequence)
      unsubscribe_module = create(:unsubscribe_module, :pages => [unsubscribe_page], :language => @portuguese)
      next_page = create(:action_page, :name => "next_page", :action_sequence => @page.action_sequence)
      user = create(:brazilian_chick, :movement => @movement, :language => @portuguese, :is_member => true)

      put :take_action, :movement_id => @movement.friendly_id, :id => unsubscribe_page.id, :member_info => { :email => user.email }, :locale => "pt"

      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
      data["next_page_identifier"].should eql "next_page"
      User.find_by_email_and_movement_id(user.email, @movement.id).is_member.should be_false
      UserActivityEvent.find_by_user_id_and_activity(user.id, UserActivityEvent::Activity::UNSUBSCRIBED).should_not be_nil
    end

    it "should not subscribe new user when trying to unsubscribe non existing member" do
      @movement.default_language = @portuguese
      unsubscribe_page = create(:action_page, :action_sequence => @page.action_sequence)
      unsubscribe_module = create(:unsubscribe_module, :pages => [unsubscribe_page], :language => @portuguese)
      next_page = create(:action_page, :name => "next_page", :action_sequence => @page.action_sequence)

      email = "casper@friendly.com"

      put :take_action, :movement_id => @movement.friendly_id, :id => unsubscribe_page.id, :member_info => { :email => email }, :locale => "pt"

      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
      data["next_page_identifier"].should eql "next_page"
      User.find_by_email_and_movement_id(email, @movement.id).should be_nil
      UserActivityEvent.includes(:user).where('users.email = ?', email).count.should eql 0
    end

    it "should not allow users to be unsubscribed via a non-unsubscribe module" do
      user = create(:user, :movement => @movement, :language => @english)

      post :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
          :member_info => { :first_name => user.first_name, :last_name => user.last_name, :email => user.email, :is_member => false },
          :locale => @english.iso_code

      User.find_by_email(user.email).is_member.should be_true
    end

    it "should not allow users to be permanently unsubscribed via a non-unsubscribe module" do
      user = create(:user, :movement => @movement, :language => @english)

      post :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
          :member_info => { :first_name => user.first_name, :last_name => user.last_name, :email => user.email, :permanently_unsubscribed => true },
          :locale => @english.iso_code

      User.find_by_email(user.email).permanently_unsubscribed.should be_nil
    end

    it "should record an 'action taken' user activity event with email id" do
      email = create(:email)
      user = create(:user, :movement => @movement, :language => @english)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :t => tracking_hash,
          :member_info => { :first_name => user.first_name, :last_name => user.last_name, :email => user.email },
          :locale => @english.iso_code

      #Delayed::Worker.new.work_off
      activity_events = UserActivityEvent.where(:movement_id => @movement.id, :page_id => @page.id,
          :campaign_id => @campaign.id, :action_sequence_id => @action_sequence.id, :content_module_id => @petition_module.id,
          :activity => UserActivityEvent::Activity::ACTION_TAKEN.to_s, :email_id => email.id, :push_id => email.blast.push.id,
          :user_id => user.id).all
          
      #binding.pry    
      activity_events.count.should == 1
      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
    end

    it "should record a 'subscribed' user activity event with email id" do
      email = create(:email)
      user = create(:user, :movement => @movement, :language => @english)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id, :t => tracking_hash,
          :member_info => { :first_name => user.first_name, :last_name => user.last_name, :email => user.email },
          :locale => @english.iso_code

      activity_events = UserActivityEvent.where(:page_id => @page.id, :content_module_id => @petition_module.id,
          :activity => UserActivityEvent::Activity::SUBSCRIBED.to_s, :email_id => email.id, :user_id => user.id).all
      activity_events.count.should == 1
      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
    end

    it "should allow actions to be taken when there's no action info provided" do
      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
          :member_info => { :first_name => "Bob", :last_name => "Johnson", :email => "bob@johnson.com" },
          :locale => "pt"

      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
    end

    it "should allow actions to be taken when there's no action info provided and it's an empty string" do
      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
          :member_info => { :first_name => "Bob", :last_name => "Johnson", :email => "bob@johnson.com" },
          :locale => "pt",
          :action_info => ""

      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 201
    end

    it "should sign unsuccessful action and error code on DuplicateActionTakenError" do
      bad_user = double
      bad_user.stub!(:take_action_on!).and_raise DuplicateActionTakenError
      User.stub_chain(:for_movement, :where).and_return [bad_user]

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
          :member_info => { :first_name => "Bob", :last_name => "Johnson", :email => "bob@johnson.com" },
          :locale => "pt",
          :action_info => ""

      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 400
      data["error"].should eql "Member already took this action"
    end

    it "should sign unsuccessful action and error code on generic error" do
      bad_user = double
      bad_user.stub!(:take_action_on!).and_raise StandardError
      User.stub_chain(:for_movement, :where).and_return [bad_user]

      put :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
          :member_info => { :first_name => "Bob", :last_name => "Johnson", :email => "bob@johnson.com" },
          :locale => "pt",
          :action_info => ""

      data = ActiveSupport::JSON.decode(response.body)
      response.status.should eql 500
      data["error"].should eql "standard_error"
    end

    context "two movements have action pages with the same name" do
      before do
        @language = FactoryGirl.create(:language)
        @allout, @allout_page, @allout_module = create_movement_with_petition("AllOut", "A unique petition page", @language)
        @walkfree, @walkfree_page, @walkfree_module = create_movement_with_petition("WalkFree", "A unique petition page", @language)
      end

      it "should take action on AllOut's page" do
        user = create(:user, :language => @language, :movement => @allout, :join_email_sent => true)

        put :take_action, :movement_id => @allout.friendly_id, :id => @allout_page.friendly_id,
            :member_info => { :email => user.email }, :locale => @language.iso_code

        actions_taken = UserActivityEvent.where(:page_id => @allout_page.id,
          :content_module_id => @allout_module.id,
          :user_id => user.id,
          :activity => UserActivityEvent::Activity::ACTION_TAKEN.to_s)
        actions_taken.count.should eql 1
      end

      it "should take action on WalkFree's page" do
        user = create(:user, :language => @language, :movement => @walkfree, :join_email_sent => true)

        put :take_action, :movement_id => @walkfree.friendly_id, :id => @walkfree_page.friendly_id,
            :member_info => { :email => user.email }, :locale => @language.iso_code

        actions_taken = UserActivityEvent.where(:page_id => @walkfree_page.id,
          :content_module_id => @walkfree_module.id,
          :user_id => user.id,
          :activity => UserActivityEvent::Activity::ACTION_TAKEN.to_s)
        actions_taken.count.should eql 1
      end

      def create_movement_with_petition(movement_name, petition_page_name, default_language)
        movement = FactoryGirl.create(:movement, :name => movement_name, :languages => [default_language])
        movement.default_language = default_language
        movement.save!

        campaign = FactoryGirl.create(:campaign, :movement => movement)
        as = FactoryGirl.create(:published_action_sequence, :campaign => campaign)
        petition_page = FactoryGirl.create(:action_page, :name => petition_page_name, :action_sequence => as)
        petition_module = FactoryGirl.create(:petition_module, :pages => [petition_page], :language => default_language)

        [movement, petition_page, petition_module]
      end
    end

    describe "sending join emails" do
      it "should not send join emails when an existing member is joining a movement" do
        user = create(:user, :language => @movement.languages.first, :movement => @movement,
            :join_email_sent => true)
        action_sequence = @page.action_sequence

        join_module = create(:join_module)
        join_page = create(:action_page, :name => "Join", :content_modules => [join_module],
            :action_sequence => action_sequence)

        put :take_action, :movement_id => @movement.friendly_id, :id => join_page.id,
            :member_info => { :email => user.email }, :locale => user.language.iso_code

        ActionMailer::Base.deliveries.size.should == 0
      end

      it "should send join emails when a new member is joining a movement" do
        user = create(:user, :language => @movement.languages.first, :movement => @movement,
            :join_email_sent => false)
        action_sequence = @page.action_sequence

        join_module = create(:join_module)
        join_page = create(:action_page, :name => "Join", :content_modules => [join_module],
            :action_sequence => action_sequence)

        put :take_action, :movement_id => @movement.friendly_id, :id => join_page.id,
            :member_info => { :email => user.email }, :locale => user.language.iso_code

        ActionMailer::Base.deliveries.size.should == 1
        ActionMailer::Base.deliveries.first.should have_subject(/Welcome/)
      end

      it "should send only the petition page autofire email when a new member is signing a petition" do
        user = create(:user, :language => @movement.languages.first, :movement => @movement,
            :join_email_sent => false)
        action_sequence = @page.action_sequence
        create(:autofire_email, :subject => "Badger badger badger badger",
            :action_page => @page, :language => @movement.languages.first)

        put :take_action, :movement_id => @movement.friendly_id, :id => @page.id,
            :member_info => { :email => user.email }, :locale => user.language.iso_code

        ActionMailer::Base.deliveries.size.should == 1
        ActionMailer::Base.deliveries.first.should have_subject(/Badger badger badger badger/)
      end
    end
  end

  describe "preview" do
    it "should return json with page content" do
      enabled_language = create(:language)
      disabled_language = create(:english)
      movement = create(:movement, languages: [enabled_language, disabled_language])
      campaign = create(:campaign, movement: movement)
      action_sequence = create(:action_sequence, :published => false, :campaign => campaign,
                               :enabled_languages => [enabled_language.iso_code])
      page = create(:action_page, :name => "Cool page", :action_sequence => action_sequence)
      header_content = create(:html_module, :title => "Header", :content => "Welcome!", :language => disabled_language)
      create(:header_module_link, :content_module => header_content, :page => page)
      MemberCountCalculator.init(page.action_sequence.campaign.movement, 10000)

      get :preview, :movement_id => page.action_sequence.campaign.movement.id, :id => page.id, :locale => disabled_language.iso_code

      data = ActiveSupport::JSON.decode(response.body)
      data["id"].should eql page.id
      data["name"].should eql "Cool page"
      data["header_content_modules"].first["title"].should eql "Header"
      data["header_content_modules"].first["content"].should eql "Welcome!"
      data["is_join_page"].should be_false
      data["member_count"].should eql "10,000"
      response.headers['Content-Language'].should eql disabled_language.iso_code
    end

    it "should return Not Found status when there's no page matching the query" do
      movement = create(:movement)
      get :preview, :movement_id => movement.id, :id => -1

      response.status.should eql 404
    end
  end

  describe "share_counts" do
    it "should return share counts for all share types for a page" do
      page = create(:action_page)

      create(:twitter_share, :page_id => page.id)
      create(:facebook_share, :page_id => page.id)
      create(:email_share, :page_id => page.id)

      get :share_counts, :movement_id => @movement.id, :id => page.id, :format => :json

      ActiveSupport::JSON.decode(response.body).should == {'facebook' => 1,
                                                           'twitter' => 1,
                                                           'email' => 1}
    end

    context "a share type has no shares" do
      it "should include the share type with zero shares" do
        page = create(:action_page)

        create(:twitter_share, :page_id => page.id)
        create(:facebook_share, :page_id => page.id)

        get :share_counts, :movement_id => @movement.id, :id => page.id, :format=>:json

        ActiveSupport::JSON.decode(response.body).should == {'facebook' => 1,
                                                             'twitter' => 1,
                                                             'email' => 0}
      end
    end
  end

  describe 'donation_payment_error' do
    before :each do
      Delayed::Worker.delay_jobs = false
      ActionMailer::Base.delivery_method = :test
    end

    it "should send payment error email" do
      member_info = { :email => 'john.smith@example.com', :first_name => 'John', :last_name => 'Smith', :country_iso => 'ar', :postcode => '1111' }
      payment_error_data = { :error_code => '9999', :message => 'Error message', :donation_payment_method => 'paypal', :donation_amount_in_cents => 100, :donation_currency => 'USD' }
      # donation_error = DonationError.new(payment_error_data.merge(member_info))
      DonationError.any_instance.should_receive(:initialize).with({
        :movement => @movement,
        :action_page => @page,
        :error_code => '9999',
        :message => 'Error message',
        :donation_payment_method => 'paypal',
        :donation_amount_in_cents => '100',
        :donation_currency => 'USD',
        :email => 'john.smith@example.com',
        :first_name => 'John',
        :last_name => 'Smith',
        :country_iso => 'ar',
        :postcode => '1111'
      })
      mail = double
      mail.should_receive(:deliver)
      PaymentErrorMailer.should_receive(:report_error).with(an_instance_of(DonationError)).and_return(mail)

      post :donation_payment_error, :movement_id => @movement.friendly_id, :id => @page.id, :payment_error_data => payment_error_data, :member_info => member_info

      response.status.should == 200
    end

    it "should send payment error email even if there is no member info available" do
      payment_error_data = { :error_code => '8888', :message => 'Error message', :donation_payment_method => 'paypal', :donation_amount_in_cents => 100, :donation_currency => 'USD' }
      # donation_error = DonationError.new(payment_error_data)
      DonationError.any_instance.should_receive(:initialize).with({
        :movement => @movement,
        :action_page => @page,
        :error_code => '8888',
        :message => 'Error message',
        :donation_payment_method => 'paypal',
        :donation_amount_in_cents => '100',
        :donation_currency => 'USD'
      })
      mail = double
      mail.should_receive(:deliver)
      PaymentErrorMailer.should_receive(:report_error).with(an_instance_of(DonationError)).and_return(mail)

      post :donation_payment_error, :movement_id => @movement.friendly_id, :id => @page.id, :payment_error_data => payment_error_data
    end
  end
end

def stringify_hash(hash)
  hash.inject({}) do |options, (key, value)|
    options[key.to_s] = value.to_s
    options
  end
end

def remove_callback_wrapper(response_body)
  response_body.gsub(/(callback)(\()/, '').gsub(/\)/, '')
end
