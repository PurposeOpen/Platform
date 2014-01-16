class AddEmailPreferencesToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :notify_of_payment_error, :boolean, :default => true
    add_column :donations, :notify_of_recurring_payment_error, :boolean, :default => true
    add_column :donations, :notify_of_donation_creation, :boolean, :default => true
    add_column :donations, :notify_of_recurring_payment, :boolean, :default => true
    add_column :donations, :notify_of_expiring_credit_card, :boolean, :default => true
  end
end
