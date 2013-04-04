class RemoveDeprecatedColumnsFromTransaction < ActiveRecord::Migration
  def up
  	remove_column :transactions, :response_code
  	remove_column :transactions, :message
  	remove_column :transactions, :txn_ref
  	remove_column :transactions, :bank_ref
  	remove_column :transactions, :action_type
  	remove_column :transactions, :refunded
  	remove_column :transactions, :refund_of_id
  	remove_column :transactions, :settled_on
  	remove_column :transactions, :fee_in_cents
  	remove_column :transactions, :status_reason
  	remove_column :transactions, :invoiced
  end

  def down
  	add_column :transactions, :response_code, :string
  	add_column :transactions, :message, :string
  	add_column :transactions, :txn_ref, :string
  	add_column :transactions, :bank_ref, :string
  	add_column :transactions, :action_type, :string
  	add_column :transactions, :refunded, :boolean, :default => false, :null => false
  	add_column :transactions, :refund_of_id, :integer
  	add_column :transactions, :settled_on, :date
  	add_column :transactions, :fee_in_cents, :integer
  	add_column :transactions, :status_reason, :string
  	add_column :transactions, :invoiced, :boolean, :default => true
  end
end
