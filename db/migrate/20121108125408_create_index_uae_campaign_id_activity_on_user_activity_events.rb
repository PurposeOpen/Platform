class CreateIndexUaeCampaignIdActivityOnUserActivityEvents < ActiveRecord::Migration
  def up
    add_index :user_activity_events, [:campaign_id, :activity], :name => :uae_campaign_id_activity
  end

  def down
    remove_index :user_activity_events, :uae_campaign_id_activity
  end
end
