class AddNextPaymentAtToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :next_payment_at, :datetime
  end
end
