class UpdateExternalIdInTransactions < ActiveRecord::Migration
  def change
    change_column :transactions, :external_id, :string, :null => true
  end
end
