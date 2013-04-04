class RemoveChequeFieldsFromDonations < ActiveRecord::Migration

  def up
    remove_column :donations, :cheque_number
    remove_column :donations, :cheque_name
    remove_column :donations, :cheque_bank
    remove_column :donations, :cheque_branch
  end

  def down
    add_column :donations, :cheque_number, :string, :limit => 128
    add_column :donations, :cheque_name, :string
    add_column :donations, :cheque_bank, :string
    add_column :donations, :cheque_branch, :string
  end
end
