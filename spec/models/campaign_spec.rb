# == Schema Information
#
# Table name: campaigns
#
#  id            :integer          not null, primary key
#  name          :string(64)
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  created_by    :string(255)
#  updated_by    :string(255)
#  alternate_key :integer
#  opt_out       :boolean          default(TRUE)
#  movement_id   :integer
#  slug          :string(255)
#

require "spec_helper"

describe Campaign do
  describe "validations" do
    it "should require a name between 3 and 64 characters" do
      Campaign.new(:name => "Save the kittens!").should be_valid
      Campaign.new(:name => "AB").should_not be_valid
      Campaign.new(:name => "X" * 64).should be_valid
      Campaign.new(:name => "Y" * 65).should_not be_valid
    end
  end

  it "should scope campaigns by movement when populating the list cutter select options" do
    walkfree = FactoryGirl.create(:movement, :name => "Walk Free")
    walkfree_campaign = FactoryGirl.create(:campaign, :name => "Walkfree Campaign", :movement => walkfree)
    allout = FactoryGirl.create(:movement, :name => "All Out")
    allout_campaign = FactoryGirl.create(:campaign, :name => "Allout Campaign", :movement => allout)


    Campaign.select_options(walkfree).should == [[ walkfree_campaign.name, walkfree_campaign.id ]]
    Campaign.select_options(allout).should == [[ allout_campaign.name, allout_campaign.id ]]
  end

  describe 'stats query' do
    before do
      @campaign = create(:campaign)
      @action_sequence = create(:action_sequence, campaign: @campaign)
    end
    it "should return member count as one and action count as 0 for join page join" do
      join_module = create(:join_module)
      join_page = create(:action_page, action_sequence: @action_sequence)
      content_module_link_for_join = create(:content_module_link, page: join_page, content_module: join_module)
      create(:subscribed_activity, campaign: @campaign, page: join_page, content_module: join_module)
      results = ActiveRecord::Base.connection.execute(@campaign.build_stats_query).entries
      results.count.should == 1
      join_module_stats = results.first
      join_module_stats.should include "JoinModule"
      join_module_stats[6].to_digits.should == "1.0"
    end

    it "should return member count and action count as 1 for peition page join" do
      petition_module = create(:petition_module)
      petition_page = create(:action_page, action_sequence: @action_sequence)
      content_module_link_for_petition = create(:content_module_link, page: petition_page, content_module: petition_module)
      create(:action_taken_activity, campaign: @campaign, page:petition_page, content_module: petition_module)
      create(:subscribed_activity, campaign: @campaign, page: petition_page, content_module: petition_module)
      results = ActiveRecord::Base.connection.execute(@campaign.build_stats_query).entries
      results.count.should == 1
      petition_module_stats = results.last
      petition_module_stats.should include "PetitionModule"
      petition_module_stats[5].to_digits.should == "1.0"
      petition_module_stats[6].to_digits.should == "1.0"
    end
  end
end
