class AddSpreedlyFieldsToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :payment_method_token, :string
    add_column :donations, :card_last_four_digits, :string
    add_column :donations, :card_exp_month, :string
    add_column :donations, :card_exp_year, :string
  end
end
