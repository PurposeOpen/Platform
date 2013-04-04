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

class CampaignShareStat < ActiveRecord::Base
  belongs_to :page, :foreign_key => :taf_page_id
  belongs_to :campaign
  self.primary_key = :taf_page_id

  def self.update!
    stats = ReadOnly.connection.execute("select share_aggregates.page_id, campaign_id, action_sequences.id, fb_shares, twitter_share, email_share from pages p
                join action_sequences on p.action_sequence_id = action_sequences.id join
                (select page_id, sum(if(share_type='facebook', 1, 0)) as fb_shares, sum(if(share_type='twitter',1, 0)) as twitter_share, sum(if(share_type='email',1, 0)) as email_share
                from shares where page_id is not null group by page_id) as share_aggregates on p.id = share_aggregates.page_id")
    stats.each do |page_id, campaign_id, action_sequence_id, facebook_shares_count, twitter_shares_count, email_shares_count|
      taf_page = Page.find(page_id)
      stat = where(:taf_page_id => page_id, :campaign_id => campaign_id).first_or_create
      stat.update_attributes(:facebook_shares => facebook_shares_count, :twitter_shares => twitter_shares_count, :email_shares => email_shares_count)
      action_page = Page.where(:position => taf_page.position - 1, :action_sequence_id => action_sequence_id).first
      activity = action_page && action_page.is_join? ? UserActivityEvent::Activity::SUBSCRIBED : UserActivityEvent::Activity::ACTION_TAKEN
      actions_before_share = action_page ? (UserActivityEvent.where(:page_id => action_page.id, :activity => activity).count) : nil
      stat.update_attributes(:actions_before_share => actions_before_share)
    end
  end

  [:facebook_shares, :twitter_shares, :email_shares].each do |share|
    define_method "#{share}_percentage" do
      actions_before_share.to_i > 0 ? "#{(send(share).to_i*100/actions_before_share)}%" : 'NA'
    end
  end
end
