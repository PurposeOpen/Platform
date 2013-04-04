class AddInvoiceIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :invoice_id, :string, :null => false
  end
end
