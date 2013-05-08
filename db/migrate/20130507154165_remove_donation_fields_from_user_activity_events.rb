class RemoveDonationFieldsFromUserActivityEvents < ActiveRecord::Migration

  def up
    remove_column :user_activity_events, :donation_amount_in_cents
    remove_column :user_activity_events, :donation_frequency
  end

  def down
    add_column :user_activity_events, :donation_frequency, :string
    add_column :user_activity_events, :donation_amount_in_cents, :integer
  end

end
