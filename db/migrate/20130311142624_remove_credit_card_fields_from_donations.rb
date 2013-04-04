class RemoveCreditCardFieldsFromDonations < ActiveRecord::Migration

  def up
    remove_column :donations, :card_type
    remove_column :donations, :card_expiry_month
    remove_column :donations, :card_expiry_year
    remove_column :donations, :card_last_four_digits
    remove_column :donations, :name_on_card
  end

  def down
    add_column :donations, :card_type, :string, :limit => 32
    add_column :donations, :card_expiry_month, :integer
    add_column :donations, :card_expiry_year, :integer
    add_column :donations, :card_last_four_digits, :string, :limit => 4
    add_column :donations, :name_on_card, :string
  end
end
