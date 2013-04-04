class AddSubscriptionIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :subscription_id, :string, :null => true
  end
end
