class ChangeCampaignIdToPageIdInCampaignShareStat < ActiveRecord::Migration
  def change
    add_column :campaign_share_stats, :taf_page_id, :integer
    rename_column :campaign_share_stats, :total_activities, :actions_before_share
  end
end
