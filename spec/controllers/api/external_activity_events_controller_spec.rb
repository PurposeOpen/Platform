require 'spec_helper'

describe Api::ExternalActivityEventsController do
  let(:external_action) { mock_model(ExternalAction, invalid?: false) }

  before do
    @english = FactoryGirl.create(:english)
    @movement = FactoryGirl.create(:movement, name: 'AllOut', languages: [@english])

    @source = 'controlshift'

    @event_params = {role: 'signer', activity: ExternalActivityEvent::Activity::ACTION_TAKEN}

    @user_attributes = {email:          'bob@example.com',
                        language_iso:   @english.iso_code,
                        first_name:     'Bob',
                        last_name:      'Harris',
                        postcode:       '10003',
                        mobile_number:  '2123246343',
                        home_number:    '6317575899',
                        street_address: '115 5th Ave',
                        suburb:         'Bondi Beach',
                        state:          'New York',
                        country_iso:    'us',
                        movement_id:    @movement.id,
                        language_id:    @english.id,
                        source:         @source,
                        is_member:      true}

    @user_params = @user_attributes.except(:movement_id, :language_id, :source)
    ExternalAction.stub(:find_or_create_by_unique_action_slug).and_return(external_action)
  end

  context 'new user taking action:' do

    it 'should create a new user, and an external activity event' do
      post :create, @event_params.merge(
        user: @user_params, 
        movement_id: @movement.slug, 
        partner: 'kenya_now', 
        action_slug: 'kenya', 
        source: @source,
        action_language_iso: @english.iso_code,), format: :json

      user = @movement.members.find_by_email('bob@example.com')
      user.should_not be_nil
      saved_user_attributes = user.attributes.symbolize_keys.slice(*@user_attributes.keys)
      saved_user_attributes.should == @user_attributes.except(:language_iso)

      external_activity_event = ExternalActivityEvent.last
      external_activity_event.should_not be_nil
      expected_event_attributes = @event_params.merge(:user_id => user.id)
      saved_event_attributes = external_activity_event.attributes.symbolize_keys.slice(*expected_event_attributes.keys)
      saved_event_attributes.should == expected_event_attributes

      response.status.should == 201
    end

  end

  context 'new user creating an action:' do

    it 'should create a new user, an action_created event, and an action_taken event' do
      created = ExternalActivityEvent::Activity::ACTION_CREATED
      taken = ExternalActivityEvent::Activity::ACTION_TAKEN

      post :create, @event_params.merge(user: @user_params, movement_id: @movement.slug, activity: created, role: 'creator', source: @source), format: :json

      user = @movement.members.find_by_email('bob@example.com')
      user.should_not be_nil
      saved_user_attributes = user.attributes.symbolize_keys.slice(*@user_attributes.keys)
      saved_user_attributes.should == @user_attributes.except(:language_iso)

      actions_created, actions_taken = ExternalActivityEvent.all.partition { |event| event.activity == created }
      actions_created.should_not be_blank
      actions_taken.should_not be_blank

      attributes_for_comparison = ExternalActivityEvent.accessible_attributes.to_a

      expected_action_created_attributes = @event_params.merge(user_id: user.id, activity: created, role: 'creator', external_action_id: external_action.id)
      saved_action_created_attributes = actions_created.first.attributes.slice(*attributes_for_comparison)
      expected_action_created_attributes.should == saved_action_created_attributes.symbolize_keys

      expected_action_taken_attributes = @event_params.merge(user_id: user.id, activity: taken, role: 'creator', external_action_id: external_action.id)
      saved_action_taken_attributes = actions_taken.first.attributes.slice(*attributes_for_comparison)
      expected_action_taken_attributes.should == saved_action_taken_attributes.symbolize_keys

      response.status.should == 201
    end

  end

  context 'existing user that did not join from an external source taking action with updated user info:' do

    it "it should update the user's info, and the user's source should not be external" do
      non_external_source = 'movement'
      aussie = FactoryGirl.create(:aussie, movement: @movement, language: @english, source: non_external_source)

      aussie_params = @user_params.clone
      aussie_params[:email] = aussie.email

      post :create, @event_params.merge(user: aussie_params, movement_id: @movement.slug), format: :json

      updated_aussie = @movement.members.find_by_email(aussie.email)
      updated_aussie_attributes = updated_aussie.attributes.symbolize_keys.slice(*@user_attributes.keys)
      updated_aussie_attributes.should == @user_attributes.except(:language_iso).merge(email: aussie.email, source: non_external_source)

      response.status.should == 201
    end

  end

  describe 'language,' do

    before do
      @french = FactoryGirl.create(:french)
      @french_movement = FactoryGirl.create(:movement, languages: [@french, @english])
    end

    context "user takes action on a page in a language that the Platform doesn't have:" do

      it "should set the user's language to the default language of the movement" do
        @french_movement.send(:demote_default_language_if_set)
        @french_movement.send(:promote_language_to_default, @french)

        event_params = @event_params.clone
        event_params[:action_language_iso] = 'zz'

        post :create, event_params.merge(user: @user_params, movement_id: @french_movement.slug), format: :json

        user = @french_movement.members.find_by_email(@user_params[:email])
        user.language.should == @french

        response.status.should == 201
      end

    end

    context "user's language is different than action language:" do

      it "should set user's language to the action language" do
        @french_movement.send(:demote_default_language_if_set)
        @french_movement.send(:promote_language_to_default, @english)

        event_params = @event_params.clone
        event_params[:action_language_iso] = @french.iso_code

        user_params = @user_params.clone
        user_params[:language_iso] = 'ww'

        post :create, event_params.merge(user: user_params, movement_id: @french_movement.slug), format: :json

        user = @french_movement.members.find_by_email(user_params[:email])
        user.language.should == @french

        response.status.should == 201
      end

    end

  end

  context "user did not opt in to the organization's list:" do

    context 'new user:' do

      it 'should create a new user that is unsubscribed' do
        user_params = @user_params.clone
        user_params[:is_member] = false

        post :create, @event_params.merge(user: user_params, movement_id: @movement.slug), format: :json

        user = User.find_by_email(user_params[:email])
        user.should_not be_nil
        user.is_member.should be_false
        user.permanently_unsubscribed.should be_false

        response.status.should == 201
      end

    end

    context 'existing user:' do

      it 'should not unsubscribe the user' do
        user = FactoryGirl.create(:user, movement: @movement)
        user_params = @user_params.clone
        user_params[:email] = user.email
        user_params[:is_member] = false

        post :create, @event_params.merge(user: user_params, movement_id: @movement.slug), format: :json

        user.reload
        user.is_member.should be_true
        user.permanently_unsubscribed.should be_false

        response.status.should == 201
      end

    end

  end

  context 'user is permanently unsubscribed' do

    it 'should not subscribe the user' do
      user = FactoryGirl.create(:user, movement: @movement, is_member: false, permanently_unsubscribed: true)
      user_params = @user_params.clone
      user_params[:email] = user.email
      user_params[:is_member] = true

      post :create, @event_params.merge(user: user_params, movement_id: @movement.slug), format: :json

      user.reload
      user.is_member.should be_false
      user.permanently_unsubscribed.should be_true

      response.status.should == 201
    end

  end

  context 'email tracking hash sent:' do

    it 'should create subscribed and action_taken events associated with the email, and record that the email was viewed and clicked' do
      blast = FactoryGirl.create(:blast)
      movement = blast.push.campaign.movement
      email = FactoryGirl.create(:email, blast: blast)
      user = FactoryGirl.create(:user, movement: movement)
      tracking_hash = EmailTrackingHash.new(email, user).encode

      user_params = @user_params.clone
      user_params[:email] = user.email

      post :create, @event_params.merge(user: user_params, movement_id: movement.slug, t: tracking_hash), format: :json

      subscribed_event, action_taken_event = UserActivityEvent.all.partition { |event| event.activity == 'subscribed' }.flatten
      subscribed_event.should_not be_nil
      subscribed_event.attributes.should include('user_id' => user.id, 'movement_id' => movement.id, 'activity' => 'subscribed', 'email_id' => email.id)

      action_taken_event.should_not be_nil
      action_taken_event.attributes.should include('user_id' => user.id, 'movement_id' => movement.id, 'activity' => 'action_taken', 'email_id' => email.id, 'push_id' => blast.push.id)

      PushClickedEmail.first.attributes.should include('user_id' => user.id, 'movement_id' => movement.id, 'email_id' => email.id, 'push_id' => blast.push.id)
      PushViewedEmail.first.attributes.should include('user_id' => user.id, 'movement_id' => movement.id, 'email_id' => email.id, 'push_id' => blast.push.id)

      response.status.should == 201
    end

  end

  context 'errors:' do

    it 'should return 500 when unable to satisfy the request' do
      event = mock('event', :invalid? => false)
      ExternalActivityEvent.should_receive(:new).and_return(event)
      event.should_receive(:save!).and_raise StandardError

      post :create, @event_params.merge(user: @user_params, movement_id: @movement.slug), format: :json

      JSON.parse(response.body).should == {"error" => "standard_error"}
      response.status.should == 500
    end

    context 'invalid user:' do

      it 'should return validation error details and status 422' do
        @user_params.delete(:email)
        post :create, @event_params.merge(user: @user_params, movement_id: @movement.slug), format: :json

        JSON.parse(response.body).should == {"email" => ["can't be blank", "is invalid"]}
        response.status.should == 422
      end

    end

    context 'invalid external activity event:' do

      it 'should return validation error details and status 422' do
        @event_params.delete(:role)
        post :create, @event_params.merge(user: @user_params, movement_id: @movement.slug), format: :json

        JSON.parse(response.body).should == {"role" => ["can't be blank"]}
        response.status.should == 422
      end
    end
  end

  describe "external action and external tags" do
    let(:movement)  { mock_model(Movement, slug: 'movement', default_language: mock_model(Language)) }
    let(:user)      { mock_model(User, :attributes= => true, take_external_action!: true) }

    before do
      movement.stub_chain(:members, :find_or_initialize_by_email).and_return(user)
      Movement.stub(:find).with(movement.slug).and_return(movement)
    end

    context 'when there is a valid external action' do
      it 'should find or create this external action' do
        ExternalAction.should_receive(:find_or_create_by_unique_action_slug).with(
          "#{movement.id}_controlshift_join", 
          {movement_id: movement.id, 
           action_slug: "join", 
           partner: "purpose", 
           source: "controlshift", 
           action_language_iso: "en"}.stringify_keys
        )
        post(:create, {
          movement_id: movement.slug, 
          source: "controlshift",
          action_slug: "join",
          partner: "purpose",
          action_language_iso: "en",
          user: {}, 
          format: :json
        })
      end

      context 'when there are tags for this external action' do
        let(:language)        { mock_model(Language) }
        let(:external_action) { mock_model(ExternalAction, :<< => true) }
        let(:tag1)            { mock_model(ExternalTag) }
        let(:tag2)            { mock_model(ExternalTag) }
        let(:tag3)            { mock_model(ExternalTag) }
        let(:external_tags)   { double(:<< => true) }

        before do
          external_action.stub(:external_tags).and_return(external_tags)
          Language.stub(:find_by_iso_code).and_return(language)
          ExternalTag.stub(:find_or_create_by_name_and_movement_id!).with("tag1", movement.id).and_return(tag1)
          ExternalTag.stub(:find_or_create_by_name_and_movement_id!).with("tag2", movement.id).and_return(tag2)
          ExternalTag.stub(:find_or_create_by_name_and_movement_id!).with("tag3", movement.id).and_return(tag3)
          ExternalAction.stub(:find_or_create_by_unique_action_slug).and_return(external_action)
        end

        it 'should find or create those tags' do
          ExternalTag.should_receive(:find_or_create_by_name_and_movement_id!).with("tag1", movement.id)
          ExternalTag.should_receive(:find_or_create_by_name_and_movement_id!).with("tag2", movement.id)
          ExternalTag.should_receive(:find_or_create_by_name_and_movement_id!).with("tag3", movement.id)
          post :create, movement_id: movement.slug, user: {}, tags: ["tag1", "tag2", "tag3"], format: :json
        end

        it 'should attribute those tags to the external action' do
          external_tags.should_receive(:<<).with(tag1)
          external_tags.should_receive(:<<).with(tag2)
          external_tags.should_receive(:<<).with(tag3)
          post :create, movement_id: movement.slug, user: {}, tags: ["tag1", "tag2", "tag3"], format: :json
        end
      end
    end

    context 'when there is an invalid external action' do
      let(:external_action) { mock_model(ExternalAction, invalid?: true, errors: "this is the external action errors") }
      before { ExternalAction.should_receive(:find_or_create_by_unique_action_slug).and_return(external_action) }

      it 'should return unprocessable entity status' do
        post :create, movement_id: movement.slug, user: {}
        response.status.should be_== 422
      end
      
      it 'should return the external action errors' do
        post :create, movement_id: movement.slug, user: {}
        response.body.should be_== "this is the external action errors".to_json
      end
    end
  end
end
