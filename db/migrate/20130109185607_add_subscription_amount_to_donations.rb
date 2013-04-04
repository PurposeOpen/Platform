class AddSubscriptionAmountToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :subscription_amount, :integer, :null => true
  end
end
