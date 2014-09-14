require 'spec_helper'

describe ListCutter::MemberActivityRule do

  describe "validations" do
    it { should validate_presence_of :activity_count_operator }
    it { should ensure_inclusion_of(:activity_count_operator).in_array(['more_than', 'less_than', 'equal_to']) }

    it { should validate_presence_of :activity_count }
    it { should validate_numericality_of(:activity_count).only_integer }
    it { should_not allow_value(-1).for(:activity_count) }

    it { should validate_presence_of :activity_module_types }
    it { should allow_value([PetitionModule.to_s]).for(:activity_module_types) }
    it { should allow_value([DonationModule.to_s]).for(:activity_module_types) }
    it { should allow_value([EmailTargetsModule.to_s]).for(:activity_module_types) }
    it { should_not allow_value(['random_event']).for(:activity_module_types) }

    it { should validate_presence_of :activity_since_date }
    it { should allow_value(Date.yesterday.strftime("%m/%d/%Y")).for(:activity_since_date) }
    it { should allow_value(Date.today.strftime("%m/%d/%Y")).for(:activity_since_date) }
    it { should_not allow_value(Date.tomorrow.strftime("%m/%d/%Y")).for(:activity_since_date) }
  end

  describe "to_relation" do

    describe "filter on multiple module types" do
      before(:each) do
        @movement = create(:movement)
        @user1 = create(:user, movement: @movement)
        @user2 = create(:user, movement: @movement)
        @user3 = create(:user, movement: @movement)
        @user4 = create(:user, movement: @movement)
        @user5 = create(:user, movement: @movement)
        @user6 = create(:user, movement: @movement)

        create(:activity, user: @user1, content_module: create(:petition_module))
        create(:activity, user: @user2, content_module: create(:donation_module))
        create(:activity, user: @user3, content_module: create(:petition_module))
        create(:activity, user: @user4, content_module: create(:email_targets_module))
        create(:email_sent_activity, user: @user5)
        create(:email_sent_activity, user: @user6)
        create(:activity, user: @user2, content_module: create(:donation_module))
        create(:activity, user: @user3, content_module: create(:petition_module))
        create(:activity, user: @user1, content_module: create(:email_targets_module))

        options = {activity_since_date: Date.yesterday.strftime("%m/%d/%Y")}
        @verifier = Proc.new do |range_operator, activity_count, expected_users, activity_module_types|
          actual_users = ListCutter::MemberActivityRule.new(options.merge(
            activity_count_operator: range_operator, 
            activity_count: activity_count, 
            activity_module_types: activity_module_types, 
            movement: @movement
          )).to_relation.all
          actual_users.should be_same_array_regardless_of_order(expected_users)
        end
      end

      it "should return users based on combinations of actions taken" do
        @verifier.call("equal_to", 2, [@user2], ['DonationModule', 'EmailTargetsModule'])
        @verifier.call("more_than", 1, [@user1, @user2, @user3], ['DonationModule', 'EmailTargetsModule', 'PetitionModule'])
        @verifier.call("equal_to", 2, [@user1, @user2, @user3], ['DonationModule', 'EmailTargetsModule', 'PetitionModule'])
        @verifier.call("more_than", 3, [], ['DonationModule', 'EmailTargetsModule', 'PetitionModule'])
        @verifier.call("more_than", 0, [@user1, @user2, @user3, @user4], ['DonationModule', 'EmailTargetsModule', 'PetitionModule'])
        @verifier.call("less_than", 1, [@user5, @user6], ['DonationModule', 'EmailTargetsModule', 'PetitionModule'])
      end
    end

    describe "filter on single module type" do
      before do
        @movement = create(:movement)
        @user1 = create(:user, movement: @movement)
        @user2 = create(:user, movement: @movement)
        @user3 = create(:user, movement: @movement)
        @user4 = create(:user, movement: @movement)
        @user5 = create(:user, movement: @movement)
        @user6 = create(:user, movement: @movement)

        create(:activity, user: @user1, content_module: create(:petition_module))
        create(:activity, user: @user2, content_module: create(:donation_module))
        create(:activity, user: @user3, content_module: create(:petition_module))
        create(:activity, user: @user4, content_module: create(:email_targets_module))
        create(:email_sent_activity, user: @user5)
        create(:email_sent_activity, user: @user6)
        create(:activity, user: @user2, content_module: create(:donation_module))
        create(:activity, user: @user3, content_module: create(:petition_module))
        create(:activity, user: @user1, content_module: create(:email_targets_module))

        options = {activity_since_date: Date.yesterday.strftime("%m/%d/%Y")}
        @verifier = Proc.new do |range_operator, activity_count, expected_users, activity_module_types|
          actual_users = ListCutter::MemberActivityRule.new(options.merge(
            activity_count_operator: range_operator, 
            activity_count: activity_count, 
            activity_module_types: activity_module_types,
            movement: @movement
          )).to_relation.all
          actual_users.should be_same_array_regardless_of_order(expected_users)
        end

      end

      it "should return users filtered on the magnitude of number of donations made" do
        @verifier.call("equal_to", 2, [@user2], ['DonationModule'])
        @verifier.call("more_than", 0, [@user2], ['DonationModule'])
        @verifier.call("equal_to", 0, [@user1, @user3, @user4, @user5, @user6], ['DonationModule'])
        @verifier.call("less_than", 2, [@user1, @user3, @user4, @user5, @user6], ['DonationModule'])
        @verifier.call("less_than", 3, [@user1, @user3, @user4, @user5, @user6, @user2], ['DonationModule'])
      end

      it "should return users filtered on the magnitude to number of petitions signed" do
        @verifier.call("equal_to", 2, [@user3], ['PetitionModule'])
        @verifier.call("more_than", 0, [@user1, @user3], ['PetitionModule'])
        @verifier.call("equal_to", 0, [@user2, @user4, @user5, @user6], ['PetitionModule'])
        @verifier.call("less_than", 2, [@user1, @user2, @user4, @user5, @user6], ['PetitionModule'])
        @verifier.call("less_than", 3, [@user1, @user3, @user4, @user5, @user6, @user2], ['PetitionModule'])
      end

      it "should return users filtered on the magnitude to number of Emails sent" do
        @verifier.call("equal_to", 2, [], ['EmailTargetsModule'])
        @verifier.call("more_than", 0, [@user1, @user4], ['EmailTargetsModule'])
        @verifier.call("equal_to", 0, [@user2, @user3, @user5, @user6], ['EmailTargetsModule'])
        @verifier.call("less_than", 2, [@user1, @user2, @user3, @user4, @user5, @user6], ['EmailTargetsModule'])
        @verifier.call("less_than", 3, [@user1, @user3, @user4, @user5, @user6, @user2], ['EmailTargetsModule'])
      end
    end

    describe "distinguish between 'subscribed' and 'action_taken' activity for members that join through: " do

      before do
        @verify = Proc.new do |content_module_type|
          movement = create(:movement)
          module1 = create(content_module_type.underscore.to_sym)
          module2 = create(content_module_type.underscore.to_sym)
          user1 = create(:user, movement: movement)
          user2 = create(:user, movement: movement)

          create(:activity, user: user1, content_module: module1, movement: movement)
          create(:subscribed_activity, user: user1, content_module: module1, movement: movement)
          create(:activity, user: user2, content_module: module1, movement: movement)
          create(:activity, user: user2, content_module: module2, movement: movement)

          options = {activity_since_date: Date.yesterday.strftime("%m/%d/%Y")}
          actual_users = ListCutter::MemberActivityRule.new(options.merge(
            activity_count_operator: 'more_than', 
            activity_count: 1, 
            activity_module_types: [content_module_type],
            movement: movement
          )).to_relation.all
          
          actual_users.should == [user2]
        end
      end

      it 'petition' do
        @verify.call('PetitionModule')
      end

      it 'donation' do
        @verify.call('DonationModule')
      end

      it 'email targets' do
        @verify.call('EmailTargetsModule')
      end

    end

  end

  describe "to_human_sql" do
    it "should return human readable form of conditions" do
      options = {activity_since_date: "12/12/2012"}
      ListCutter::MemberActivityRule.new(options.merge(not: false, activity_count_operator: "more_than", activity_count: 2, activity_module_types: ['DonationModule'])).to_human_sql.should == "Member Activity is More Than 2 actions in any of these: DonationModule since 12/12/2012"
      ListCutter::MemberActivityRule.new(options.merge(not: true, activity_count_operator: "more_than", activity_count: 2, activity_module_types: ['DonationModule'])).to_human_sql.should == "Member Activity is not More Than 2 actions in any of these: DonationModule since 12/12/2012"
      ListCutter::MemberActivityRule.new(options.merge(not: false, activity_count_operator: "less_than", activity_count: 2, activity_module_types: ['DonationModule', 'EmailTargetsModule'])).to_human_sql.should == "Member Activity is Less Than 2 actions in any of these: DonationModule, EmailTargetsModule since 12/12/2012"
      ListCutter::MemberActivityRule.new(options.merge(not: true, activity_count_operator: "equal_to", activity_count: 2, activity_module_types: ['DonationModule'])).to_human_sql.should == "Member Activity is not Equal To 2 actions in any of these: DonationModule since 12/12/2012"
    end
  end
end
