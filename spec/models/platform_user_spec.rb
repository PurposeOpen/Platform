# == Schema Information
#
# Table name: platform_users
#
#  id                     :integer          not null, primary key
#  email                  :string(256)      not null
#  first_name             :string(64)
#  last_name              :string(64)
#  mobile_number          :string(32)
#  home_number            :string(32)
#  encrypted_password     :string(255)
#  password_salt          :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  is_admin               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

require 'spec_helper'

describe PlatformUser do
  describe "names" do
    it "full_name should have a full name, or Unknown Username if neither first nor last names are present" do
      create(:platform_user, :first_name => "rico").full_name.should == "Rico"
      create(:platform_user, :last_name => "ferhandez").full_name.should == "Ferhandez"
      create(:platform_user, :first_name => "rico", :last_name => "ferhandez").full_name.should == "Rico Ferhandez"
      create(:platform_user, :first_name => "", :last_name => "").full_name.should == "Unknown Username"
    end

    it "name should have a full name, or Unknown Username if neither first nor last names are present" do
      create(:platform_user, :first_name => "rico").name.should == "Rico"
      create(:platform_user, :last_name => "ferhandez").name.should == "Ferhandez"
      create(:platform_user, :first_name => "rico", :last_name => "ferhandez").name.should == "Rico Ferhandez"
      create(:platform_user, :first_name => "", :last_name => "").name.should == "Unknown Username"
    end
  end

  describe "#movements_allowed" do
    before(:each) do
      @movement_a = create(:movement, :name => "Save the walruses!",)
      @movement_b = create(:movement, :name => "Save the wolphins!")
      @movement_c = create(:movement, :name => "Save the ferrets!")
      @movement_d = create(:movement, :name => "Save the monkeys!")
    end

    it "should return all movements if I am a platform admin" do
      platform_admin = create(:platform_user, :is_admin => true)
      platform_admin.movements_allowed.should =~ Movement.all
    end

    it "should return all movements I am an admin or campaigner or senior campaigner for" do
      user = create(:platform_user, :is_admin => false)
      create(:user_affiliation, :movement_id => @movement_a.id, :user_id => user.id, :role => UserAffiliation::ADMIN)
      create(:user_affiliation, :movement_id => @movement_b.id, :user_id => user.id, :role => UserAffiliation::CAMPAIGNER)
      create(:user_affiliation, :movement_id => @movement_d.id, :user_id => user.id, :role => UserAffiliation::SENIOR_CAMPAIGNER)
      user.movements_allowed.should == [@movement_a, @movement_b, @movement_d]
    end
  end

  describe "#movements_administered" do
    before(:each) do
      @movements = []
      5.times do
        @movements << build(:movement)
      end
      Movement.stub(:all) {(@movements)}
    end

    it "should return all movements if I am a Platform Admin" do
      user = create(:admin_platform_user)
      user.movements_administered.size.should == 5
      user.movements_administered.should == @movements
    end

    it "should return movements I am an admin for if I am not a Platform Admin" do
      movement1 = create(:movement)
      movement2 = create(:movement)
      user = create(:platform_user)
      user.user_affiliations = [UserAffiliation.new(:movement_id => movement1.id, :user_id => user.id, :role => UserAffiliation::ADMIN), UserAffiliation.new(:movement_id => movement2.id, :user_id => user.id, :role => UserAffiliation::CAMPAIGNER)]

      user.movements_administered.should == [movement1]
    end

    it "should return nothing if I am not an Admin" do
      movement1 = create(:movement)
      movement2 = create(:movement)
      user = create(:platform_user)
      user.user_affiliations = [UserAffiliation.new(:movement_id => movement1.id, :user_id => user.id, :role => UserAffiliation::CAMPAIGNER),
                                UserAffiliation.new(:movement_id => movement2.id, :user_id => user.id, :role => UserAffiliation::SENIOR_CAMPAIGNER)]
      user.movements_administered.should be_empty
    end
  end

  describe "#is_campaigner?" do
    before(:each) do
      @user = create(:platform_user, is_admin: false)
      @movement = create(:movement)
    end

    it "should be true if I am a campaigner on a movement" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::CAMPAIGNER)
      @user.is_campaigner?.should be_true
    end

    it "should be false if I am not a campaigner on any movement" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::ADMIN)
      @user.is_campaigner?.should be_false
    end

    it "should return false if the user has no user affiliations" do
      @user.is_campaigner?.should be_false
    end
  end

  describe "#is_senior_campaigner?" do
    before(:each) do
      @user = create(:platform_user, is_admin: false)
      @movement = create(:movement)
    end

    it "should be true if I am a senior campaigner on a movement" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::SENIOR_CAMPAIGNER)
      @user.is_senior_campaigner?.should be_true
    end

    it "should be false if I am not a senior campaigner on any movement" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::ADMIN)
      @user.is_senior_campaigner?.should be_false
    end

    it "should return false if the user has no user affiliations" do
      @user.is_senior_campaigner?.should be_false
    end
  end

  describe "#is_movement_admin?" do
    before(:each) do
      @user = create(:platform_user, is_admin: false)
      @movement = create(:movement)
    end

    it "should return true if the user is a movement admin" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::ADMIN)
      @user.is_movement_admin?.should be_true
    end

    it "should return false if the user is not a movement admin" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::CAMPAIGNER)
      @user.is_movement_admin?.should be_false
    end

    it "should return false if the user has no user affiliations" do
      @user.is_movement_admin?.should be_false
    end
  end

  describe "#creating a platform user" do
    it "should send a confirmation email after creation" do
      create(:platform_user)
      ActionMailer::Base.should have(1).deliveries
    end
  end

  describe "#has_user_affiliations?" do
    before(:each) do
      @user = create(:platform_user)
      @movement = create(:movement)
    end

    it "should return true if there are any affiliations" do
      create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::ADMIN)
      @user.should have_user_affiliations
    end

    it "should return false if there are no affiliations" do
      @user.should_not have_user_affiliations
    end
  end

  describe "#user_affiliation_for_movement" do
    before(:each) do
      @user = create(:platform_user)
      @movement = create(:movement)
    end

    it "should return user affiliation for the movement" do
      user_affiliation = create(:user_affiliation, platform_user: @user, movement: @movement, role: UserAffiliation::ADMIN)
      @user.user_affiliation_for_movement(@movement).should == user_affiliation
    end

    it "should return nil if there are no user affiliations" do
      @user.user_affiliation_for_movement(@movement).should be_nil
    end
  end

end
