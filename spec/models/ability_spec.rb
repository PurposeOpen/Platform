require "spec_helper"
require "cancan/matchers"

describe Ability do

  describe "movement" do
    before(:each) do
      @movement_a = create(:movement, name: "Save the walruses!")
      @movement_b = create(:movement, name: "Save the dolphins!")
    end

    it "should authorize all movements for platform admin" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @movement_a)
      ability.should be_able_to(:manage, @movement_b)
    end
    
    it "should authorize movements for movement admin" do
      user = create(:platform_user, is_admin: false)
      create(:user_affiliation, platform_user: user, movement: @movement_b, role: UserAffiliation::ADMIN)      
      ability = Ability.new(user)
      ability.should_not be_able_to(:read, @movement_a)
      ability.should_not be_able_to(:update, @movement_a)
      ability.should_not be_able_to(:destroy, @movement_a)

      ability.should be_able_to(:read, @movement_b)
      ability.should be_able_to(:update, @movement_b)
      ability.should be_able_to(:destroy, @movement_b)

      ability.should_not be_able_to(:create, Movement)
    end

    shared_examples_for "authorize movement for campaigner roles" do |role|
      it "should authorize movement for #{role}" do
        user = create(:platform_user, is_admin: false)
        create(:user_affiliation, platform_user: user, movement: @movement_b, role: role)
        ability = Ability.new(user)
        ability.should_not be_able_to(:read, @movement_a)
        ability.should_not be_able_to(:update, @movement_a)
        ability.should_not be_able_to(:destroy, @movement_a)

        ability.should be_able_to(:read, @movement_b)
        ability.should_not be_able_to(:update, @movement_b)
        ability.should_not be_able_to(:destroy, @movement_b)

        ability.should_not be_able_to(:create, Movement)
      end
    end

    it_should_behave_like "authorize movement for campaigner roles", UserAffiliation::CAMPAIGNER
    it_should_behave_like "authorize movement for campaigner roles", UserAffiliation::SENIOR_CAMPAIGNER

    it "should authorize movements for multiple user affiliations" do
      user = create(:platform_user, is_admin: false)
      movement = create(:movement, name: "Save everything")
      create(:user_affiliation, platform_user: user, movement: @movement_a, role: UserAffiliation::ADMIN)
      create(:user_affiliation, platform_user: user, movement: @movement_b, role: UserAffiliation::CAMPAIGNER)
      create(:user_affiliation, platform_user: user, movement: movement, role: UserAffiliation::SENIOR_CAMPAIGNER)
      ability = Ability.new(user)
      ability.should be_able_to(:read, @movement_a)
      ability.should be_able_to(:update, @movement_a)
      ability.should be_able_to(:destroy, @movement_a)

      ability.should be_able_to(:read, movement)
      ability.should_not be_able_to(:update, movement)
      ability.should_not be_able_to(:destroy, movement)

      ability.should be_able_to(:read, @movement_b)
      ability.should_not be_able_to(:update, @movement_b)
      ability.should_not be_able_to(:destroy, @movement_b)

      ability.should_not be_able_to(:create, Movement)
    end

  end

  describe "toggle_platform_admin" do
    it "should authorize toggling of platform admin for platform admin" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:toggle_platform_admin_role, PlatformUser)
    end

    shared_examples_for "should not authorize toggling of platform admin for non-platform admin" do |role|
      it "for role - #{role}" do
        user = create(:platform_user, is_admin: false)
        movement = create(:movement)
        create(:user_affiliation, platform_user: user, movement: movement, role: role)
        ability = Ability.new(user)
        ability.should_not be_able_to(:toggle_platform_admin_role, PlatformUser)
      end
    end

    UserAffiliation::ROLES.each {|role| it_should_behave_like "should not authorize toggling of platform admin for non-platform admin", role }
  end

  describe "JoinEmail" do
    before(:each) do
      @movement_a = create(:movement, name: "Save the walruses!",)
      @movement_b = create(:movement, name: "Save the dolphins!")
      @join_email_a = build(:join_email)
      @join_email_b = build(:join_email)
      create(:movement_locale, join_email: @join_email_a, movement: @movement_a)
      create(:movement_locale, join_email: @join_email_b, movement: @movement_b)
    end

    it "should authorize all join emails for platform admin" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @join_email_a)
      ability.should be_able_to(:manage, @join_email_b)
    end

    shared_examples_for "should authorize join mails for non-platform admin" do |role|
      it "for role - #{role}" do
        user = create(:platform_user, is_admin: false)
        create(:user_affiliation, platform_user: user, movement: @movement_a, role: role)
        ability = Ability.new(user)
        ability.should be_able_to(:manage, @join_email_a)
        ability.should_not be_able_to(:manage, @join_email_b)
      end
    end

    UserAffiliation::ROLES.each {|role| it_should_behave_like "should authorize join mails for non-platform admin", role }
  end

  describe "EmailFooter" do
    before(:each) do
      @movement_a = create(:movement, name: "Save the walruses!",)
      @movement_b = create(:movement, name: "Save the dolphins!")
      @email_footer_a = build(:email_footer)
      @email_footer_b = build(:email_footer)
      create(:movement_locale, email_footer: @email_footer_a, movement: @movement_a)
      create(:movement_locale, email_footer: @email_footer_b, movement: @movement_b)
    end

    it "should authorize all email footers for platform admin" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @email_footer_a)
      ability.should be_able_to(:manage, @email_footer_b)
    end

    shared_examples_for "should authorize email footers for non-platform admin" do |role|
      it "for role - #{role}" do
        user = create(:platform_user, is_admin: false)
        create(:user_affiliation, platform_user: user, movement: @movement_a, role: role)
        ability = Ability.new(user)
        ability.should be_able_to(:manage, @email_footer_a)
        ability.should_not be_able_to(:manage, @email_footer_b)
      end
    end

    UserAffiliation::ROLES.each {|role| it_should_behave_like "should authorize email footers for non-platform admin", role }
  end

  describe "HomePage" do
    before(:each) do
      @movement_a = create(:movement, name: "Save the walruses!",)
      @movement_b = create(:movement, name: "Save the dolphins!")
      @homepage_a = create(:homepage, movement: @movement_a)
      @homepage_b = create(:homepage, movement: @movement_b)
    end

    it "should authorize all home pages for platform admin" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @homepage_a)
      ability.should be_able_to(:manage, @homepage_b)
    end

    it "should authorize homepages for movement admin" do
      user = create(:platform_user, is_admin: false)
      create(:user_affiliation, platform_user: user, movement: @movement_a, role: UserAffiliation::ADMIN)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @homepage_a)
      ability.should_not be_able_to(:manage, @homepage_b)
    end

    shared_examples_for "should not authorize home pages for campaigner roles" do |role|
      it "for role - #{role}" do
        user = create(:platform_user, is_admin: false)
        create(:user_affiliation, platform_user: user, movement: @movement_a, role: role)
        ability = Ability.new(user)
        ability.should_not be_able_to(:manage, @homepage_a)
        ability.should_not be_able_to(:manage, @homepage_b)
      end
    end

    [UserAffiliation::CAMPAIGNER, UserAffiliation::SENIOR_CAMPAIGNER].each {|role| it_should_behave_like "should not authorize home pages for campaigner roles", role }
  end

  describe "Campaign" do
    before(:each) do
      @movement_a = create(:movement, name: "Save the walruses!",)
      @movement_b = create(:movement, name: "Save the dolphins!")
      @campaign_a = create(:campaign, movement: @movement_a)
      @campaign_b = create(:campaign, movement: @movement_b)
    end

    it "should authorize all campaigns for platform admin" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @campaign_a)
      ability.should be_able_to(:manage, @campaign_b)
    end

    it "should authorize campaigns for movement admin" do
      user = create(:platform_user, is_admin: false)
      create(:user_affiliation, platform_user: user, movement: @movement_a, role: UserAffiliation::ADMIN)
      ability = Ability.new(user)
      ability.should be_able_to(:manage, @campaign_a)
      ability.should_not be_able_to(:manage, @campaign_b)
    end

    shared_examples_for "should not authorize campaigns for campaigner roles" do |role|
      it "for role - #{role}" do
        user = create(:platform_user, is_admin: false)
        create(:user_affiliation, platform_user: user, movement: @movement_a, role: role)
        ability = Ability.new(user)
        ability.should_not be_able_to(:manage, @campaign_a)
        ability.should_not be_able_to(:manage, @campaign_b)
      end
    end

    [UserAffiliation::CAMPAIGNER, UserAffiliation::SENIOR_CAMPAIGNER].each {|role| it_should_behave_like "should not authorize campaigns for campaigner roles", role }
  end

  describe "send Blast" do
    before(:each) do
      @movement_a = create(:movement, name: "Save the walruses!",)
      @movement_b = create(:movement, name: "Save the dolphins!")
      @blast_a = create(:blast, push: build(:push, campaign: build(:campaign, movement: @movement_a)))
      @blast_b = create(:blast, push: build(:push, campaign: build(:campaign, movement: @movement_b)))
    end

    it "should authorize send permission for all blast mails" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:send, @blast_a)
      ability.should be_able_to(:send, @blast_b)
    end

    it "should authorize send permission to blast mails for senior campaigner" do
      user = create(:platform_user, is_admin: false)
      create(:user_affiliation, platform_user: user, movement: @movement_a, role: UserAffiliation::SENIOR_CAMPAIGNER)
      ability = Ability.new(user)
      ability.should be_able_to(:send, @blast_a)
      ability.should_not be_able_to(:send, @blast_b)
    end

    it "should authorize send permission to blast mails for movement admins" do
      user = create(:platform_user, is_admin: false)
      create(:user_affiliation, platform_user: user, movement: @movement_a, role: UserAffiliation::ADMIN)
      ability = Ability.new(user)
      ability.should be_able_to(:send, @blast_a)
      ability.should_not be_able_to(:send, @blast_b)
    end

    it "should not authorize send permission to blast mails for movement campaigners" do
      user = create(:platform_user, is_admin: false)
      create(:user_affiliation, platform_user: user, movement: @movement_a, role: UserAffiliation::CAMPAIGNER)
      ability = Ability.new(user)
      ability.should_not be_able_to(:send, @blast_a)
      ability.should_not be_able_to(:send, @blast_b)
    end
  end

  describe "PlatformUser" do
    it "should be able to read, create and update for platform admins" do
      user = create(:platform_user, is_admin: true)
      ability = Ability.new(user)
      ability.should be_able_to(:read, PlatformUser)
      ability.should be_able_to(:create, PlatformUser)
      ability.should be_able_to(:update, PlatformUser)
    end

    it "should be able to read, create and update for movement admins" do
      user = create(:platform_user, is_admin: false)
      movement = create(:movement)
      create(:user_affiliation, platform_user: user, movement: movement, role: UserAffiliation::ADMIN)
      ability = Ability.new(user)
      ability.should be_able_to(:read, PlatformUser)
      ability.should be_able_to(:create, PlatformUser)
      ability.should be_able_to(:update, PlatformUser)
    end

    shared_examples_for "should not be able to read, create and update for campaigner roles" do |role|
      it "for role - #{role}" do
        user = create(:platform_user, is_admin: false)
        movement = create(:movement)
        create(:user_affiliation, platform_user: user, movement: movement, role: role)
        ability = Ability.new(user)
        ability.should_not be_able_to(:read, PlatformUser)
        ability.should_not be_able_to(:create, PlatformUser)
        ability.should_not be_able_to(:update, PlatformUser)
      end
    end

    [UserAffiliation::SENIOR_CAMPAIGNER, UserAffiliation::CAMPAIGNER].each do |role|
      it_should_behave_like "should not be able to read, create and update for campaigner roles", role
    end
  end

end