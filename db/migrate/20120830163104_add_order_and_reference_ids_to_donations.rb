class AddOrderAndReferenceIdsToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :order_id, :string
    add_column :donations, :transaction_id, :string
  end
end
