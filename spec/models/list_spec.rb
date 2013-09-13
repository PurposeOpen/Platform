# == Schema Information
#
# Table name: lists
#
#  id                           :integer          not null, primary key
#  rules                        :text             default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  blast_id                     :integer
#  saved_intermediate_result_id :integer
#

require "spec_helper"
require "benchmark"

describe List do
  let(:movement) { create(:movement) }

  let(:blast) {
    campaign = create(:campaign, :movement => movement)
    push = create(:push, :campaign => campaign)
    create(:blast, :push => push)
  }

  let(:email) {
    create(:email, :blast => blast, :language => movement.default_language)
  }

  let(:list) {
    List.new(:blast => blast)
  }

  let(:default_relation) { User.where(:is_member => true).where(:movement_id => movement.id) }

  context 'list is destroyed' do
    it 'paranoia should preserve the record and set deleted_at' do
      list = create(:list)
      list.destroy

      List.with_deleted.find(list.id).should == list
    end
  end
  
  it "should return users whose email belong to gmail" do
    user = create(:user, :email => "foo@borges.com", :movement => movement, :language => movement.default_language)
    activity = create(:activity, :user => user)
    list.add_rule(:email_domain_rule, :domain => "@borges.com")

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.should =~ [ activity.user.id ]
  end

  it "should return brazilian users" do
    u1 = create(:user, :movement => movement, :country_iso => "BR", :language => movement.default_language)
    u2 = create(:user, :movement => movement, :country_iso => "BR", :language => movement.default_language)
    activity = create(:activity, :user => u1)
    brazilian_activity = create(:brazilian_activity, :user => u2)

    list.add_rule(:country_rule, :selected_by => 'name', :values => ["BRAZIL"])

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.size.should == 2
    users.should include(activity.user.id, brazilian_activity.user.id)
  end

  it "should only return users that have recurring activities if recurring required" do
    users = (1..5).map {|_| create(:user, :movement => movement, :language => movement.default_language)}
    donation_one_off_1 = create(:donation, :frequency => "one_off", :user => users[0])
    donation_one_off_2 = create(:donation, :frequency => "one_off", :user => users[1])
    donation_weekly_1 = create(:donation, :frequency => "weekly", :user => users[2], :subscription_id => '2222')
    donation_weekly_2 = create(:donation, :frequency => "weekly", :user => users[3], :subscription_id => '3333')
    donation_monthly_1 = create(:donation, :frequency => "monthly", :user => users[4], :subscription_id => '4444')

    list.add_rule(:donor_rule, :frequencies => [:one_off])

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.size.should == 2
    users.should include(donation_one_off_1.user.id, donation_one_off_2.user.id)

    list.rules.clear
    list.add_rule(:donor_rule, :frequencies => [:one_off, :weekly])

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.size.should == 4
  end

  it "should only return users that have participated in campaigns" do
    user = create(:user, :movement => movement, :language => movement.default_language)
    action_taken_activity = create(:action_taken_activity, :user => user, :movement => movement)

    list.add_rule(:campaign_rule, :campaigns => [action_taken_activity.campaign.id])

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.should =~ [ user.id ]
  end

  it "should return users that took action" do
    u1 = create(:user, :movement => movement, :country_iso => "AU", :language => movement.default_language)
    u2 = create(:user, :movement => movement, :country_iso => "AU", :language => movement.default_language)
    action_taken_activity = create(:action_taken_activity, :user => u1, :movement => movement)
    create(:subscribed_activity, :user => u2, :movement => movement)

    list.add_rule(:action_taken_rule, :page_ids => [action_taken_activity.page.id])
    list.add_rule(:country_rule, :selected_by => 'name', :values => ["AUSTRALIA"])

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.size.should == 1
    users[0].should == action_taken_activity.user.id
  end

  it "should aggregate individual rules validation errors" do
    list.add_rule :action_taken_rule, {}
    list.add_rule :email_domain_rule, {}

    list.valid?.should be_false
    expected_errors = {
      :action_taken_rule=>[{
        :page_ids=>["Please specify the page ids"]
      }],
      :email_domain_rule=>[{
        :domain=>["Please specify the email server"]
      }]
    }
    list.errors.messages.should == expected_errors
  end

  it "should return all users if no filter specified" do
    another_aussie = create(:aussie_in_edgewater, :movement => movement, :language => movement.default_language)
    sydney_aussie = create(:aussie, :movement => movement, :language => movement.default_language)

    list.valid?.should be_true

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.size.should == 2
    users.should include another_aussie.id
    users.should include sydney_aussie.id
  end

  it "should return distinct users based on the user activities" do
    user = create(:leo, :movement => movement, :language => movement.default_language)
    activity = create(:activity, :user => user, :page_id => 1)
    activity1 = create(:activity, :user => user, :page_id => 1)

    list.add_rule(:action_taken_rule, :page_ids => ["1"])

    users = list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1)
    users.size.should == 1
    users[0].should == activity.user.id
  end

  it "should find users by domain and country" do
    @user1 = create(:user, :movement => movement, :is_member => true, :country_iso => "BR", :email => "johan@gmail.com", :language => movement.default_language)
    @user2 = create(:user, :movement => movement, :is_member => true, :country_iso => "AR", :email => "johan@yahoo.com", :language => movement.default_language)
    @user3 = create(:user, :movement => movement, :is_member => true, :country_iso => "EE", :email => "jacko@gmail.com", :language => movement.default_language)

    list.add_rule(:email_domain_rule, :domain => "gmail.com")
    list.add_rule(:country_rule, :selected_by => 'name', :values => ["BRAZIL", "ARGENTINA"])
    list.save

    list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1).should == [@user1.id]
  end

  describe "using filters of the same type multiple times" do
    before do
      @campaign1 = create(:campaign, :movement => movement)
      @action_sequence1 = create(:action_sequence, :campaign => @campaign1)
      @action_page1 = create(:action_page, :action_sequence => @action_sequence1)

      @campaign2 = create(:campaign, :movement => movement)
      @action_sequence2 = create(:action_sequence, :campaign => @campaign2)
      @action_page2 = create(:action_page, :action_sequence => @action_sequence2)

      @campaign3 = create(:campaign, :movement => movement)
      @action_sequence3 = create(:action_sequence, :campaign => @campaign3)
      @action_page3 = create(:action_page, :action_sequence => @action_sequence3)

      @campaign4 = create(:campaign, :movement => movement)
      @action_sequence4 = create(:action_sequence, :campaign => @campaign4)
      @action_page4 = create(:action_page, :action_sequence => @action_sequence4)

      @user1 = create(:user, :movement => movement, :is_member => true, :language => movement.default_language)
      @user2 = create(:user, :movement => movement, :is_member => true, :language => movement.default_language)
      @user3 = create(:user, :movement => movement, :is_member => true, :language => movement.default_language)
    end

    it "should return only the user who has taken an action on all campaigns specified by each campaign rule" do
      create(:action_taken_activity, :page => @action_page1, :user => @user1, :campaign => @campaign1)
      create(:action_taken_activity, :page => @action_page3, :user => @user1, :campaign => @campaign3)

      create(:action_taken_activity, :page => @action_page2, :user => @user2, :campaign => @campaign2)
      create(:action_taken_activity, :page => @action_page3, :user => @user2, :campaign => @campaign3)

      create(:action_taken_activity, :page => @action_page3, :user => @user3, :campaign => @campaign3)

      list.add_rule(:campaign_rule, :campaigns => [@campaign1, @campaign2])
      list.add_rule(:campaign_rule, :campaigns => [@campaign3])
      list.save

      list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1).should == [@user1.id, @user2.id]
    end

    it "should allow combinations of negated rules with other rules of the same type" do
      create(:action_taken_activity, :page => @action_page1, :user => @user1, :campaign => @campaign1)
      create(:action_taken_activity, :page => @action_page3, :user => @user1, :campaign => @campaign3)

      create(:action_taken_activity, :page => @action_page2, :user => @user2, :campaign => @campaign2)
      create(:action_taken_activity, :page => @action_page3, :user => @user2, :campaign => @campaign3)
      create(:action_taken_activity, :page => @action_page4, :user => @user2, :campaign => @campaign4)

      create(:action_taken_activity, :page => @action_page1, :user => @user3, :campaign => @campaign1)

      list.add_rule(:campaign_rule, :campaigns => [@campaign1, @campaign2])
      list.add_rule(:campaign_rule, :campaigns => [@campaign3])
      list.add_rule(:campaign_rule, :not => true, :campaigns => [@campaign4])
      list.save

      list.filter_by_rules_excluding_users_from_push(email, :no_jobs => 1).should == [@user1.id]
    end
  end

  describe "count" do
    before do
      @english = create(:english)

      @movement = create(:movement, :languages => [@english])
      @campaign = create(:campaign, :movement => @movement)

      @push = create(:push, :campaign => @campaign)
      @blast = create(:blast, :push => @push)
      @email = create(:email, :blast => @blast, :language => @english)

      @user1 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
      @user2 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
      @user3 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
    end

    it "should filter out users that have already received an email within the given push" do
      Push.log_activity!(:email_sent, @user1, @email)

      list = List.create!(:blast => @blast)
      list.add_rule(:country_rule, :selected_by => 'name', :values => ['UNITED STATES'])

      list.count_by_rules_excluding_users_from_push.should == { 'English' => 2 }
    end

    it "should use given rules instead of saved ones if available" do
      spanish = create(:spanish)
      user4 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'AR', :language => spanish)

      list = List.create!(:blast => @blast)
      list.add_rule(:country_rule, :selected_by => 'name', :values => ['UNITED STATES'])
      
      new_country_rule = ListCutter::CountryRule.new(:movement => @movement, :selected_by => 'name', :values => ['ARGENTINA'])

      list.count_by_rules_excluding_users_from_push([new_country_rule]).should == { 'Spanish' => 1}
    end
  end

  describe "excluding specific users" do
    it "should filter out users that have already received an email within the given push" do
      users = ['user1@gmail.com', 'user2@gmail.com', 'user3@gmail.com'].map do |email|
        create(:user, :email => email, :country_iso => 'AU', :movement => movement, :language => movement.default_language)
      end

      push = email.blast.push

      Push.log_activity!(:email_sent, users[0], email)
      create(:subscribed_activity, :user => users[1])
      create(:subscribed_activity, :user => users[2])

      user_ids = list.filter_by_rules_excluding_users_from_push(email)
      user_ids.should =~ [users[1].id, users[2].id]
    end
    
    context "limit" do
      before do
        @english = create(:language)

        @movement = create(:movement, :languages => [@english])
        @campaign = create(:campaign, :movement => @movement)

        @push = create(:push, :campaign => @campaign)
        @blast = create(:blast, :push => @push)
        @email = create(:email, :language => @english, :blast => @blast)
      end

      it "should correctly split the users on limited lists" do
        user1 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
        user2 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
        user3 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
        user4 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
        user5 = create(:user, :movement => @movement, :is_member => true, :country_iso => 'US', :language => @english)
        users = [user1, user2, user3, user4, user5]

        list = List.create!(:blast => @blast)
        list.add_rule(:country_rule, :selected_by => 'name', :values => ['UNITED STATES'])

        us_users_for_1st_deliver = list.filter_by_rules_excluding_users_from_push(@email, :no_jobs => 1, :current_job_id => 0, :limit => 2)
        Push.log_activity!(:email_sent, users.find {|u| u.id == us_users_for_1st_deliver[0] }, @email)
        Push.log_activity!(:email_sent, users.find {|u| u.id == us_users_for_1st_deliver[1] }, @email)
        us_users_for_2nd_deliver = list.filter_by_rules_excluding_users_from_push(@email, :no_jobs => 1, :current_job_id => 0, :limit => 2)
        Push.log_activity!(:email_sent, users.find {|u| u.id == us_users_for_2nd_deliver[0] }, @email)
        Push.log_activity!(:email_sent, users.find {|u| u.id == us_users_for_2nd_deliver[1] }, @email)
        us_users_for_3rd_deliver = list.filter_by_rules_excluding_users_from_push(@email, :no_jobs => 1, :current_job_id => 0, :limit => 2)

        us_users_for_1st_deliver.count.should == 2
        us_users_for_2nd_deliver.count.should == 2
        us_users_for_3rd_deliver.count.should == 1
      end

      it "should allow a limit to be added to the final query sorting by the user's random column" do
        random = 4
        users = ['user1@gmail.com', 'user2@gmail.com', 'user3@gmail.com', 'user4@gmail.com'].inject([]) do |acc, email|
          user = create(:user, :email => email, :country_iso => 'AU', :movement => movement, :language => movement.default_language)
          user.random = random
          user.save
          random -= 1
          acc << user
          acc
        end

        email = create(:email, :language => users[0].language, :blast => blast)
        Push.log_activity!(:email_sent, users[0], email)

        list.filter_by_rules_excluding_users_from_push(email).size.should == 3
        result = list.filter_by_rules_excluding_users_from_push(email, :limit => 2)
        result.size.should == 2
        result.should == [users[3].id, users[2].id]
      end
    end

    it "should not persist the excluded users rule" do
      list.add_rule(:country_rule, :selected_by => 'name', :values => ["AUSTRALIA"])
      email = create(:email)
      push = email.blast.push
      list.filter_by_rules_excluding_users_from_push(email)
      list.should have(1).rules
      list.rules.first.should be_instance_of ListCutter::CountryRule
    end
  end

  describe 'build' do
    let(:blast) { create(:blast) }

    let(:params) {
      {
      :blast_id => blast.id,
      :rules => {
        :country_rule => {
          "0" => {:activate => "1", :selected_by => 'name', :values => ["AUSTRALIA"]},
          "1" => {:activate => "1", :not => "true", :selected_by => 'name', :values => ["BRAZIL"]}
        },
        :email_domain_rule => {
           "0" => {:activate => "1", :domain => "@gmail.com"},
           "1" => {:activate => "0", :domain => "@hotmail.com"}
        },
        :campaign_rule => {
          "1" => {:activate => "1", :campaigns => "1,2,3"},
          "2" => {:activate => "1", :campaigns => "4"}
          }
        }
      }
    }

    it 'should build new list' do
      @list = List.build(params)
    end

    it 'should clear the rules and build for existing list' do
      existing_list = create(:list, :blast => blast)
      existing_list.add_rule(:email_domain_rule, :domain => "@gmail.com")
      existing_list.save
      params.merge!(:list_id => existing_list.id)
      @list = List.build(params)
      @list.id.should == existing_list.id
    end

    after do
      @list.should_not be_nil
      @list.rules.size.should == 5

      @list.rules[0].class.should eql ListCutter::CountryRule
      @list.rules[0].negate?.should be_false
      @list.rules[0].selected_by.should eql 'name'
      @list.rules[0].values.should eql ["AUSTRALIA"]

      @list.rules[1].class.should eql ListCutter::CountryRule
      @list.rules[1].negate?.should be_true
      @list.rules[1].selected_by.should eql 'name'
      @list.rules[1].values.should eql ["BRAZIL"]

      @list.rules[2].class.should eql ListCutter::EmailDomainRule
      @list.rules[2].negate?.should be_false
      @list.rules[2].domain.should eql "gmail.com"

      @list.rules[3].class.should eql ListCutter::CampaignRule
      @list.rules[3].negate?.should be_false
      @list.rules[3].campaigns.should eql "1,2,3"

      @list.rules[4].class.should eql ListCutter::CampaignRule
      @list.rules[4].negate?.should be_false
      @list.rules[4].campaigns.should eql "4"
    end
  end

  describe "sqls" do
    before(:each) do
      movement = create(:movement)
      campaign = create(:campaign, movement: movement)
      push = create(:push, campaign: campaign)
      @blast = create(:blast, push: push)
      @language_name_1, @language_name_2 = "English", "Portuguese"
      english, portuguese = [@language_name_1, @language_name_2].map { |language_name| create(:language, name: language_name) }
      create(:user, language: english, movement: movement, country_iso: "us")
      create(:user, language: english, movement: movement, country_iso: "in")
      create(:user, language: portuguese, movement: movement, country_iso: "uk")
      Country.stub(:countries_in_zone).with("us").and_return("us")
    end

    describe "empty_rule_set" do
      let(:list) { create(:list, rules: [], blast: @blast) }

      it "should return language counts for empty rule set" do
        results = list.count_by_rules_excluding_users_from_push
        results.should == { @language_name_1 => 2, @language_name_2 => 1 }
      end
    end

    describe "list_with_rules" do
      let(:list) do
        list = create(:list, rules: [], blast: @blast)
        list.add_rule(:zone_rule, :zone_code => "us")
        list
      end

      it "should return language_breakdown_sql for list with rules" do
        list.count_by_rules_excluding_users_from_push.should == { @language_name_1 => 1 }
      end
    end
  end

  describe "saved_intermediate_result delegates" do
    it "should return summary of saved_intermediate_result" do
      list = create(:list, saved_intermediate_result: create(:list_intermediate_result, data: {}))
      list.summary.should == {}
    end

    it "should return nil if no saved_intermediate_result" do
      list = create(:list, saved_intermediate_result: nil)
      list.summary.should be_nil
    end

    it "should return user count of saved intermediate results" do
      list = create(:list, saved_intermediate_result: create(:list_intermediate_result, :data => {:number_of_selected_users => 5}))
      list.user_count.should == 5
    end

    it "should return nil if no saved intermediate results" do
      list = create(:list, saved_intermediate_result: nil)
      list.user_count.should be_nil
    end
  end

end
