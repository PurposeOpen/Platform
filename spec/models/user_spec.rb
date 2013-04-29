# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      not null
#  first_name               :string(64)
#  last_name                :string(64)
#  mobile_number            :string(32)
#  home_number              :string(32)
#  street_address           :string(128)
#  suburb                   :string(64)
#  country_iso              :string(2)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  is_member                :boolean          default(TRUE), not null
#  encrypted_password       :string(255)      default("!K1T7en$!!2011G")
#  password_salt            :string(255)
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  deleted_at               :datetime
#  is_admin                 :boolean          default(FALSE)
#  created_by               :string(255)
#  updated_by               :string(255)
#  postcode_id              :integer
#  is_volunteer             :boolean          default(FALSE)
#  random                   :float
#  movement_id              :integer          not null
#  language_id              :integer
#  postcode                 :string(255)
#  join_email_sent          :boolean
#  name_safe                :boolean
#  source                   :string(255)
#  permanently_unsubscribed :boolean
#  state                    :string(64)
#

require "spec_helper"

describe User do

  describe '#permanently_unsubscribe!' do
    let(:ordinary_user) { FactoryGirl.create(:user) }
    before { ordinary_user.permanently_unsubscribe! }
    subject { ordinary_user }

    it { should_not be_member }
    its(:can_subscribe?) { should be_false }
  end

  describe "knowing whether a details field has been entered previously" do
    it "should be entered if user has been saved with a value in the field" do
      user = FactoryGirl.create(:user, :first_name => "Bob")
      user.already_entered?(:first_name).should be_true
    end
    it "should not be entered if a user has not been saved with a value in the field (probably means validation failure)" do
      user = FactoryGirl.build(:user, :first_name => "Bob")
      user.already_entered?(:first_name).should be_false
    end
    it "should not be entered if the user has been saved with no value in the field" do
      user = FactoryGirl.create(:user, :first_name => "", :last_name => nil)
      user.already_entered?(:first_name).should be_false
      user.already_entered?(:last_name).should be_false
    end
  end
  
  describe 'entered_fields' do
    it "should return the user detail fields that have been entered" do
      user = FactoryGirl.create(:user, :first_name => "Bob", :country_iso => 'US')
      
      entered_fields = user.entered_fields
      (['email', 'first_name', 'country_iso'] - entered_fields).should eql []
      entered_fields.include?('last_name').should be_false
    end
  end

  describe "names" do
    it "should have a titlecased, HTML safe greeting for emails etc." do
      FactoryGirl.create(:user, :first_name => "ferhandez").greeting.should == "Ferhandez"
      FactoryGirl.create(:user, :first_name => nil).greeting.should == nil
    end

    it "should have a full name, or Unknown Username if neither first nor last names are present" do
      FactoryGirl.create(:user, :first_name => "rico").full_name.should == "Rico"
      FactoryGirl.create(:user, :last_name => "ferhandez").full_name.should == "Ferhandez"
      FactoryGirl.create(:user, :first_name => "rico", :last_name => "ferhandez").full_name.should == "Rico Ferhandez"
      FactoryGirl.create(:user, :first_name => "", :last_name => "").full_name.should == "Unknown Username"
    end
  end

  describe "validation" do
    before(:each) do
      @required_user_details = {:first_name => :required, :last_name => :optional, :home_number => :required}
    end

    it "must have a valid email address" do
      User.new(:email => "me@email.com").should be_valid
      User.new(:email => nil).should_not be_valid
      User.new(:email => "me@email").should_not be_valid
    end

    it "should add an error message for blank email" do
      user = User.new
      user.valid?.should be_false
      user.errors.messages[:email].include?("can't be blank").should be_true
    end

    it "must have all fields required by page" do
      user = FactoryGirl.create(:user, :first_name => "Sanchez", :last_name => "Bob", :home_number => "")
      user.required_user_details = @required_user_details
      user.should_not be_valid
      user.home_number = '90632781'
      user.should be_valid
    end

    it "should not complain if optional fields are empty" do
      user = FactoryGirl.create(:user, :first_name => "Sanchez", :last_name => "", :home_number => "0009990002")
      user.required_user_details = @required_user_details
      user.should be_valid
    end

    it "validates max lengths for all supplied fields" do
      user = FactoryGirl.create(:user, :first_name => "Sanchez", :last_name => "Bob")
      user.required_user_details = @required_user_details

      user.home_number = "X" * 2000
      user.should_not be_valid
      user.home_number = '90632781'
      user.should be_valid

      user.last_name = "Y" * 2000
      user.should_not be_valid
      user.last_name = 'Bobson'
      user.should be_valid
    end

    #TODO uncomment once database is clean again
    #it "should validate first and last names as alpha-dash if present" do
    #  user = FactoryGirl.build(:user, :first_name => "@m breaking your$ d#tabase", :last_name => "z#man")
    #  user.valid?.should be_false
    #
    #  user.first_name = "Maybe-Now"
    #  user.valid?.should be_false
    #
    #  user.last_name = "Ok I'm Good now"
    #  user.valid?.should be_true
    #end
    #
    #it "should validate the phone number" do
    #  user = FactoryGirl.build(:user)
    #  test_inputs = {
    #      "0406 735 200"     => true,
    #      "(02) 9234 1600"   => true,
    #      "+61 2 9234 1600"  => true,
    #      "02-9324-1600"     => true,
    #      "abc(2)"           => false,
    #      "2(232) 312"       => true,
    #      "0406735200"       => true,
    #      "www.yourdomain.org.au" => false
    #  }
    #
    #  test_inputs.each do |k,v|
    #    user.home_number = k
    #    user.valid?.should eql v
    #  end
    #end
    #it "should prevent URLs from being entered in the address and suburb fields" do
    #  user = FactoryGirl.build(:user, :street_address => "http://IshouldNotBeHere.com", :suburb => "http://meNeither.com")
    #  user.valid?.should be_false
    #
    #  user.street_address = "345, Nice St."
    #  user.valid?.should be_false
    #
    #  user.suburb = "Sydney"
    #  user.valid?.should be_true
    #end

  end

  describe "having a postcode" do
    before(:each) do
      @fitzroy_postcode = "3065"
    end

    it "looks up the postcode when #postcode_number is set" do
      u = User.new(:postcode_number => "3065")
      u.postcode.should == @fitzroy_postcode
    end

    it "renders number from postcode when #postcode_number is called" do
      u = User.new(:postcode => @fitzroy_postcode)
      u.postcode_number.should == "3065"
    end

    it "does not require a postcode" do
      u = User.new(:postcode => nil)
      u.postcode_number.should == nil
    end

    it "validates presence of postcode" do
      u = User.new(:email => "someone@somewhere.com", :postcode_number => "")
      u.required_user_details = {:postcode_number => :refresh}
      u.should_not be_valid
      u.postcode_number = "3065"
      u.should be_valid
    end
  end

  describe "activity events" do
    describe "new users" do
      before(:each) do
        @action_page = FactoryGirl.create(:action_page)
        @movement = @action_page.movement
        @language = @movement.languages.first
        @petition = FactoryGirl.create(:petition_module, :pages => [@action_page], :language => @language)

        @join_page = FactoryGirl.create(:action_page, :name => 'join', :action_sequence => @action_page.action_sequence)
        @join_module = FactoryGirl.create(:join_module, :pages => [@join_page], :language => @language)
        
        @user = FactoryGirl.create(:user, :movement => @movement, :language => @language, :source => nil)
      end

      context "joining a movement through the movement's homepage" do
        it "should create a subscribed event associated with movement's join page and join module" do
          @user.subscribe_through_homepage!

          @user.should have(1).user_activity_events
          @user.is_member.should be_true
          @user.source.should eql :movement
          activity_event = @user.user_activity_events.first
          activity_event.movement_id.should eql @movement.id
          activity_event.activity.should eql :subscribed
          activity_event.content_module_id.should == @join_module.id
          activity_event.page_id.should == @join_page.id
          activity_event.action_sequence_id.should == @join_page.action_sequence.id
          activity_event.campaign_id.should == @join_page.action_sequence.campaign.id
          activity_event.movement_id.should == @movement.id
        end

        it "should not create a subscribed event if the user is permanently unsubscribed" do
          @user.permanently_unsubscribe!
          number_of_existing_activity_events = @user.user_activity_events.size
          
          @user.subscribe_through_homepage!
          
          @user.user_activity_events.reload.size.should == number_of_existing_activity_events
          @user.should_not be_member
        end

        it "should not create two subscribed events if a user subscribes twice from the homepage" do
          @user.take_action_on!(@join_page)
          @user.take_action_on!(@join_page)

          @user.should have(1).user_activity_events
          @user.is_member.should be_true
          activity_event = @user.user_activity_events.first
          activity_event.movement_id.should eql @movement.id
          activity_event.activity.should eql :subscribed
        end
      end

      context "joining a movement by taking an action" do
        it "should create a subscribed event associated with that page's ask module" do
          @user.subscribe_through!(@action_page)

          @user.should have(1).user_activity_events
          @user.is_member.should be_true
          @user.source.should eql :movement
          activity_event = @user.user_activity_events.first
          activity_event.activity.should eql :subscribed
          activity_event.movement_id.should eql @movement.id
          activity_event.campaign_id.should eql @action_page.action_sequence.campaign.id
          activity_event.action_sequence_id.should eql @action_page.action_sequence.id
          activity_event.page_id.should eql @action_page.id
          activity_event.content_module_id.should eql @petition.id
          activity_event.content_module_type.should eql PetitionModule.name
        end

        it "should not create a subscribed event if the user is permanently unsubscribed" do
          @user.permanently_unsubscribe!
          number_of_existing_activity_events = @user.user_activity_events.size
          
          @user.subscribe_through!(@action_page)
          
          @user.user_activity_events.reload.size.should == number_of_existing_activity_events
          @user.should_not be_member
        end
      end

      context "joining a movement through an action page" do
        it "should create a subscribed event associated with the join module" do
          @user.subscribe_through!(@join_page)

          @user.should have(1).user_activity_events
          @user.is_member.should be_true
          activity_event = @user.user_activity_events.first
          activity_event.activity.should eql :subscribed
          activity_event.page_id.should eql @join_page.id
          activity_event.content_module_id.should eql @join_module.id
          activity_event.content_module_type.should eql JoinModule.name
        end

        it "should not create a subscribed event if the user is permanently unsubscribed" do
          @user.permanently_unsubscribe!
          number_of_existing_activity_events = @user.user_activity_events.size
          
          @user.subscribe_through!(@join_page)

          @user.user_activity_events.reload.size.should == number_of_existing_activity_events
          @user.should_not be_member
        end
      end

      context "joining from the homepage and then taking an action on a page" do
        it "should create only one subscribed event" do
          @user.subscribe_through_homepage!
          @user.subscribe_through!(@join_page)

          subscribed_events = @user.user_activity_events.where(:activity => UserActivityEvent::Activity::SUBSCRIBED)
          subscribed_events.count.should eql 1
        end
      end

      context "taking an action on an unsubscribe page" do
        it "should not create a subscribed event if the email on the unsubscribe request does not belong to any user" do
          unsubscribe_page = FactoryGirl.create(:action_page, :action_sequence => @action_page.action_sequence)
          unsubscribe_module = FactoryGirl.create(:unsubscribe_module, :pages => [unsubscribe_page], :language => @language)
          
          @user = FactoryGirl.build(:user, :email => "kikkoman@soy.com", :movement => @movement, :language => @language)
          @user.take_action_on!(unsubscribe_page)

          User.for_movement(@movement).find_by_email("kikkoman@soy.com").should be_nil
          UserActivityEvent.where(:activity => UserActivityEvent::Activity::SUBSCRIBED, :content_module_id => unsubscribe_module.id).any?.should be_false
          UserActivityEvent.where(:activity => UserActivityEvent::Activity::UNSUBSCRIBED, :content_module_id => unsubscribe_module.id).any?.should be_false
        end
      end

      it "does not create an event automatically" do
        @user.is_member = true
        @user.save!
        @user.should have(0).user_activity_events
      end
    end

    describe "unsubscribed existing users" do
      before(:each) do
        @join_page = FactoryGirl.create(:action_page, :name => 'join')
        @user = FactoryGirl.create(:user, :is_member => false, movement: @join_page.movement)
      end

      it "becomes a member again if subscribing one more time" do
        @user.subscribe_through_homepage!

        @user.is_member.should be_true
        @user.should have(1).user_activity_events
        @user.user_activity_events.first.activity.should == :subscribed
      end
    end
  end

  describe "capturing information when responding to an ask" do
    it "saves an email even if other user details are not valid" do
      user = User.new
      required_details = {:first_name => :refresh}
      movement = FactoryGirl.create(:movement)
      user.save_with_valid_email(required_details, {:email => "valid@useful.com", :first_name => nil, :movement => movement}, nil, nil, nil)
      user.should be_persisted
      user.should_not be_valid
    end
  end

  describe "unsubscribe" do
    it "should change member status to false and add an unsubscribed activity event" do
      user = FactoryGirl.create(:user, :is_member => true)
      user.is_member?.should be_true
      UserActivityEvent.should_receive("unsubscribed!").with(user, nil)

      user.unsubscribe!
      user.is_member?.should be_false
    end

    it "should change member status to false and add an unsubscribed activity event belonging to an email" do
      email = FactoryGirl.create(:email)
      user = FactoryGirl.create(:user, :is_member => true)
      user.is_member?.should be_true
      UserActivityEvent.should_receive("unsubscribed!").with(user, email)

      user.unsubscribe!(email)
      user.is_member?.should be_false
    end
  end

  describe "After creation" do
    it "should update its random column" do
      u = FactoryGirl.create(:user)
      u.random.should_not be_nil
    end
  end

  describe "#update_random_values" do
    it "should update all users' random values" do
      u = FactoryGirl.create(:user)
      u1 = FactoryGirl.create(:user)
      r = u.random
      r1 = u.random

      User.update_random_values

      u.reload
      u1.reload
      u.random.should_not eql r
      u1.random.should_not eql r1
    end
  end

  describe "#umbrella_user" do
    it "should return the offline donatinos umbrella user" do
      movement = FactoryGirl.create(:movement)
      User.create(:first_name => "Umbrella", :last_name => "User", :email => 'offlinedonations@yourdomain.org', :movement => movement)

      "offlinedonations@yourdomain.org".should eql User.umbrella_user.email
    end
  end

  describe "name profanity filter" do
    it "should mark a name as safe if it does not contain profanity" do
      user = FactoryGirl.create(:user)
      user.name_safe.should be_true
    end

    it "should mark a name as unsafe if it contains profanity" do
      user = FactoryGirl.create(:user, :first_name => "Bob", :last_name => "Mierda")
      user.name_safe.should == false

      user = FactoryGirl.create(:user, :first_name => "Mierda", :last_name => "Villa")
      user.name_safe.should == false
    end
  end

  describe 'language_iso_code' do
    it "should be uppercase language iso code" do
      user = build(:user, language: build(:language, iso_code: 'en'))
      user.language_iso_code.should == 'EN'
    end

    it "should be nil if user language is not present" do
      user = build(:user, language: nil)
      user.language_iso_code.should be_nil
    end
  end


  describe 'country_iso_code' do
    it "should be uppercase country iso" do
      user = build(:user, country_iso: 'us')
      user.country_iso_code.should == 'US'
    end

    it "should be nil if country iso is not present" do
      user = build(:user, country_iso: nil)
      user.country_iso_code.should be_nil
    end
  end

  describe "subscribed & unsubscribed" do
    before(:each) do
      @subscribed_user = create(:user, is_member: true)
      @unsubscribed_user = create(:user, is_member: false)
    end

    it "should return all subscribed users" do
      User.subscribed.should == [@subscribed_user]
    end

    it "should return all unsubscribed users" do
      User.unsubscribed.should == [@unsubscribed_user]
    end
  end

end
