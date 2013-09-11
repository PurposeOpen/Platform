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
      Campaign.new(name: "Save the kittens!").should be_valid
      Campaign.new(name: "AB").should_not be_valid
      Campaign.new(name: "X" * 64).should be_valid
      Campaign.new(name: "Y" * 65).should_not be_valid
    end
  end

  it "should scope campaigns by movement when populating the list cutter select options" do
    walkfree = FactoryGirl.create(:movement, name: "Walk Free")
    walkfree_campaign = FactoryGirl.create(:campaign, name: "Walkfree Campaign", movement: walkfree)
    allout = FactoryGirl.create(:movement, name: "All Out")
    allout_campaign = FactoryGirl.create(:campaign, name: "Allout Campaign", movement: allout)


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

  context "campaign is deleted" do
    before do
      @campaign = create(:campaign)
      @action_sequence = create(:action_sequence, campaign: @campaign)
      @action_page = create(:action_page, action_sequence: @action_sequence)
      default_language = @action_page.movement.default_language
      @petition_module = create(:petition_module, language: default_language)
      @html_module = create(:html_module)
      @action_page.content_modules = [@html_module, @petition_module]
      autofire_email = create(:autofire_email, enabled: false, action_page: @action_page, language: default_language)

      @push = create(:push, campaign: @campaign)
      @blast = create(:blast, push: @push)
      @email = create(:email, blast: @blast)
      @list = create(:list, blast: @blast)
      @list_intermediate_result = create(:list_intermediate_result, list: @list)
    end

    it "should remove the campaign, action sequences, pages, links between the pages and content modules, autofire emails,
                          pushes, blasts, emails, lists, list intermediate results" do
      @campaign.destroy

      ActionSequence.where(id: @action_sequence.id).should be_blank
      Page.where(id: @action_page.id).should be_blank
      ContentModuleLink.where(page_id: @action_page.id).should be_blank
      AutofireEmail.where(action_page_id: @action_page.id).should be_blank
      ContentModule.where(id: [@petition_module.id, @html_module.id]).count.should == 2

      Push.where(id: @push.id).should be_blank
      Blast.where(id: @blast.id).should be_blank
      Email.where(id: @email.id).should be_blank
      List.where(id: @list.id).should be_blank
      ListIntermediateResult.where(id: @list_intermediate_result.id).should be_blank
    end

    it "should not destroy all content module links for shared content modules" do
      page_sharing_content_module = create(:action_page)
      page_sharing_content_module.content_modules = [@html_module]

      @campaign.destroy

      page_sharing_content_module.reload
      page_sharing_content_module.content_modules.should == [@html_module]
    end
  end

end
