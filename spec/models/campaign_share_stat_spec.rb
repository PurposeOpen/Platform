# == Schema Information
#
# Table name: campaign_share_stats
#
#  campaign_id          :integer          not null
#  facebook_shares      :integer
#  twitter_shares       :integer
#  email_shares         :integer
#  actions_before_share :integer
#  taf_page_id          :integer          primary key
#

require 'spec_helper'

describe CampaignShareStat do
  context '#update_campaign_share_stats' do
    it 'should create campaign_share_stats if stats are not available' do
      taf_module_link1 = create(:taf_module_link)
      taf_module_link2 = create(:taf_module_link)
      3.times {create(:facebook_share, :page_id => taf_module_link1.page.id)}
      2.times {create(:twitter_share, :page_id => taf_module_link1.page.id)}
      1.times {create(:email_share, :page_id => taf_module_link2.page.id)}
      CampaignShareStat.update!
      campaign_share_stat = CampaignShareStat.where(:taf_page_id => taf_module_link1.page.id).first
      campaign_share_stat.facebook_shares.should == 3
      campaign_share_stat.twitter_shares.should == 2
      campaign_share_stat.email_shares.should == 0
      campaign_share_stat = CampaignShareStat.where(:taf_page_id => taf_module_link2.page.id).first
      campaign_share_stat.twitter_shares.should == 0
      campaign_share_stat.email_shares.should == 1
    end

    it 'should update campaign_share_stats if stats are available' do
      taf_module_link = create(:taf_module_link)
      taf_page = taf_module_link.page
      existing_campaign_share_stat = create(:campaign_share_stat,
                                            :taf_page_id => taf_page.id,
                                            :campaign => taf_page.campaign,
                                            :facebook_shares => nil, :twitter_shares => nil, :email_shares => nil)
      create(:facebook_share, :page_id => taf_module_link.page.id)
      2.times {create(:twitter_share, :page_id => taf_module_link.page.id)}
      CampaignShareStat.update!
      existing_campaign_share_stat.reload.facebook_shares.should == 1
      existing_campaign_share_stat.twitter_shares.should == 2
      existing_campaign_share_stat.email_shares.should == 0
    end

    it "should update count of subscribed actions if a join page preceeds taf_page in action_sequence" do
      campaign = create(:campaign)
      action_sequence = create(:action_sequence, :campaign => campaign)
      action_page = create(:action_page, :action_sequence => action_sequence)
      join_module = create(:join_module)
      content_module_link = create(:content_module_link, :page => action_page, :content_module => join_module)
      taf_page = create(:action_page, :action_sequence => action_sequence)
      subscribed_activity = create(:subscribed_activity, :page => action_page)
      taf_module_link = create(:taf_module_link, :page => taf_page)
      3.times {create(:facebook_share, :page_id => taf_module_link.page.id)}
      CampaignShareStat.update!
      CampaignShareStat.where(:taf_page_id => taf_page.id).first.actions_before_share.should == 1
    end

    it 'should update count of action_taken activities if pages other_than join page preceed a taf_page in action_sequence' do
      campaign = create(:campaign)
      action_sequence = create(:action_sequence, :campaign => campaign)
      action_page1 = create(:action_page, :action_sequence => action_sequence)
      action_page2 = create(:action_page, :action_sequence => action_sequence)
      taf_page = create(:action_page, :action_sequence => action_sequence)
      create(:action_taken_activity, :page => action_page1)
      create(:subscribed_activity, :page => action_page1)
      2.times { create(:action_taken_activity, :page => action_page2) }
      taf_module_link1 = create(:taf_module_link, :page => taf_page)
      3.times {create(:facebook_share, :page_id => taf_module_link1.page.id)}
      CampaignShareStat.update!
      CampaignShareStat.where(:taf_page_id => taf_page.id).first.actions_before_share.should == 2

      action_page2.destroy
      CampaignShareStat.update!
      CampaignShareStat.where(:taf_page_id => taf_page.id).first.actions_before_share.should == 1
    end
  end

  context '#share_percentage' do
    it 'should return as NA if actions_before_share is 0' do
      taf_module_link = create(:taf_module_link)
      taf_page = taf_module_link.page
      stat = build(:campaign_share_stat, :taf_page_id => taf_page.id, :campaign => taf_page.campaign ,:facebook_shares => 12, :twitter_shares => nil, :email_shares => 1, :actions_before_share => nil)
      stat.facebook_shares_percentage.should == 'NA'
      stat.twitter_shares_percentage.should == 'NA'
      stat.email_shares_percentage.should == 'NA'
    end

    it 'should return percentage if actions_before_share is greater than 0' do
      taf_module_link = create(:taf_module_link)
      taf_page = taf_module_link.page
      stat = build(:campaign_share_stat, :taf_page_id => taf_page.id, :campaign => taf_page.campaign, :facebook_shares => 12, :twitter_shares => nil, :email_shares => 1, :actions_before_share => 100)
      stat.facebook_shares_percentage.should == '12%'
      stat.twitter_shares_percentage.should == '0%'
      stat.email_shares_percentage.should == '1%'
    end
  end
end
