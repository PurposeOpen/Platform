class UpdateInvoiceIdInTransactions < ActiveRecord::Migration
  def change
    change_column :transactions, :invoice_id, :string, :null => true
  end
end
