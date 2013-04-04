class AddSubscriptionFeedEnabledToMovements < ActiveRecord::Migration
  def change
    add_column :movements, :subscription_feed_enabled, :boolean
  end
end
