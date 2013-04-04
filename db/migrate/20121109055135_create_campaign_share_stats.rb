class CreateCampaignShareStats < ActiveRecord::Migration
  def change
    create_table :campaign_share_stats, :id => false do |t|
      t.integer :campaign_id, :null => false
      t.integer :facebook_shares
      t.integer :twitter_shares
      t.integer :email_shares
      t.integer :total_activities
    end
    add_index :campaign_share_stats, :campaign_id, :unique => true
  end
end
