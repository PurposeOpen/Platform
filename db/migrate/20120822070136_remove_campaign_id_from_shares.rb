class RemoveCampaignIdFromShares < ActiveRecord::Migration
  def up
    remove_column :shares, :campaign_id
  end

  def down
    add_column :shares, :campaign_id, :integer
  end
end
