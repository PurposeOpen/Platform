require 'spec_helper'

describe Api::MembersController do
  describe 'create' do
    before :each do
      @join_page = FactoryGirl.create(:action_page, name: 'join')
      @movement = @join_page.movement
    end

    it 'should send a join email after creating or saving the user' do
      join_email = ENV['JOIN_EMAIL_TO']

      language = @movement.movement_locales.first.language
      email = @movement.movement_locales.first.join_email
      email.from = 'movement@here.com'
      email.subject = 'Hi there'
      email.body = 'Thanks for joining, Mr. Helpful'
      email.save
      member_email = "lemmy@kilmister.com"

      post :create, :format => :json, :member => {:email => member_email, :language => 'en'}, :movement_id => @movement.id

      member = User.find_by_email(member_email)
      member.join_email_sent.should be_true

      ActionMailer::Base.deliveries.size.should == 1
      mail = ActionMailer::Base.deliveries.first
      mail.from.should eql ['movement@here.com']
      mail.to.should eql [join_email]
      mail.subject.should eql 'Hi there'
    end

    it "should create a new member unless they exist, and return the member id" do
      post :create, :format => :json, :member => {:email => "lemmy@kilmister.com", :language => 'en'}, :movement_id => @movement.id

      response.status.should == 201

      json = JSON.parse(response.body)
      json['member_id'].should == User.find_by_email('lemmy@kilmister.com').id
    end

    context 'a welcome page does not exist' do

      it "should create a new member unless they exist, and return blank next page id" do
        post :create, :format => :json, :member => {:email => "lemmy@kilmister.com", :language => 'en'}, :movement_id => @movement.id

        response.status.should == 201

        json = JSON.parse(response.body)
        json['next_page_identifier'].should == 'join'
        json['email'].should == 'lemmy@kilmister.com'
        User.where(:email => 'lemmy@kilmister.com', :movement_id => @movement.id).size.should == 1
      end

    end

    context 'a join page exists' do

      it "should create a new member unless they exist, set their language, and return join page next page id" do
        spanish = FactoryGirl.create(:spanish)
        FactoryGirl.create(:movement_locale, :language => spanish, :movement => @movement)
        campaign = FactoryGirl.create(:campaign, :movement => @movement)
        movement_action_sequence = FactoryGirl.create(:action_sequence, :campaign => campaign)

        post :create, :format => :json, :member => {:email => "lemmy@kilmister.com", :language => 'es'},
            :movement_id => @movement.id

        response.status.should == 201

        json = JSON.parse(response.body)
        json['next_page_identifier'].should == 'join'
        json['email'].should == 'lemmy@kilmister.com'

        member = User.where(:email => 'lemmy@kilmister.com', :movement_id => @movement.id).first
        member.language.iso_code.should == 'es'
      end

    end

    context 'member cannot be created with the attributes provided' do
      it 'should return status 422 unprocessable entity when email is missing' do
        post :create, :format => :json, :member => {}, :movement_id => @movement.id

        response.status.should == 422

        json = JSON.parse(response.body)
        json['next_page_identifier'].should be_blank
        json['errors'].should_not be_blank
      end

      it 'should return status 422 unprocessable entity when email is invalid' do
        post :create, :format => :json, :member => {:email => "chocolate_rain", :language => :en}, :movement_id => @movement.id

        response.status.should == 422

        json = JSON.parse(response.body)
        json['next_page_identifier'].should be_blank
        json['errors'].should_not be_blank
      end

      it "should return status 422 unprocessable entity when language is not provided" do
        post :create, :format => :json, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id

        response.status.should == 422

        json = JSON.parse(response.body)
        json['next_page_identifier'].should be_blank
        json['errors'].should_not be_blank
      end
    end

    context 'member tries to join twice' do
      it "should not overwrite their existing attributes" do
        member_attrs = FactoryGirl.attributes_for(:user,
          :email => "lemmy@kilmister.com",
          :first_name => "lemmy",
          :last_name => "kilmister"
        )

        user = User.new(member_attrs.merge(:movement_id => @movement.id))
        user.save!

        post :create, :format => :json, :member => {:email => "lemmy@kilmister.com", :language => 'en'}, :movement_id => @movement.id

        json = JSON.parse(response.body)

        response.status.should == 201
        json['next_page_identifier'].should == 'join'
        json['email'].should == 'lemmy@kilmister.com'
        member = @movement.members.where(:email => "lemmy@kilmister.com").first
        member.first_name.should == "lemmy"
        member.last_name.should == "kilmister"
      end
    end

    it "should be able to create new members for different movements with the same email addresss" do
      email = "lemmy@kilmister.com"
      FactoryGirl.create(:user, :email => email, :movement => @movement)

      another_action_page = create(:action_page, name: 'join' )
      another_movement = another_action_page.movement
      post :create, :member => {:email => email, :language => 'en'}, :movement_id => another_movement.id, :format => :json

      response.status.should == 201
    end

    context "member joins after getting on the homepage through a link on an email sent to a friend" do
      it "should create a subscribed user activity event associated with that email" do
        language = @movement.languages.first
        user = FactoryGirl.create(:user, :movement => @movement)
        email = FactoryGirl.create(:email)
        tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

        new_member_email = "lemmy@kilmister.com"
        post :create, :format => :json, :member => {:email => new_member_email, :language => 'en'},
            :movement_id => @movement.id, :t => tracking_hash

        newly_created_user = User.find_by_email(new_member_email)
        UserActivityEvent.where(:activity => UserActivityEvent::Activity::SUBSCRIBED.to_s,
            :email_id => email.id, :user_id => newly_created_user.id,
            :content_module_id => nil).count.should eql 1
      end
    end
  end

  describe 'show' do
    before do
      @movement = FactoryGirl.create(:movement)
      @member = FactoryGirl.create(:user, :movement => @movement, 
        :email => 'john.doe@example.com', :first_name => 'John', :last_name => 'Doe', :country_iso => 'us', :postcode => '10011', 
        :home_number => '555-5555', :mobile_number => '444-4444', :street_address => "John's place", :suburb => 'NY')
    end

    it "should retrieve user by email with only significant fields" do
      get :show, :movement_id => @movement.id, :email => 'john.doe@example.com'

      response.status.should == 200

      json = JSON.parse(response.body)

      json.length.should == 10
      json['id'].should == @member.id
      json['first_name'].should == @member.first_name
      json['last_name'].should == @member.last_name
      json['email'].should == @member.email
      json['country_iso'].should == @member.country_iso
      json['postcode'].should == @member.postcode
      json['home_number'].should == @member.home_number
      json['mobile_number'].should == @member.mobile_number
      json['street_address'].should == @member.street_address
      json['suburb'].should == @member.suburb
    end

    it "should return HTTP 404 (Not Found) if cannot find user by email" do
      get :show, :movement_id => @movement.id, :email => 'user.does.not@exist.com'

      response.status.should == 404
    end

    it "should return HTTP 400 (Bad Request) if email is not sent in request" do
      get :show, :movement_id => @movement.id

      response.status.should == 400
    end
  end

end
