class AddCurrencyAndAmountInDollarsToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :currency, :string
    add_column :donations, :amount_in_dollar_cents, :integer
  end
end
