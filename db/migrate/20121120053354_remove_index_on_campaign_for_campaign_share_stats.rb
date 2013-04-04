class RemoveIndexOnCampaignForCampaignShareStats < ActiveRecord::Migration
  def up
    remove_index :campaign_share_stats, :campaign_id
  end

  def down
    add_index :campaign_share_stats, :campaign_id
  end
end
