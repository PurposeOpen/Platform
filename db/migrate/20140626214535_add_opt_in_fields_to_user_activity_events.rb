class AddOptInFieldsToUserActivityEvents < ActiveRecord::Migration
  def change
    add_column :user_activity_events, :opt_in_ip_address, :string
    add_column :user_activity_events, :opt_in_url, :string
  end
end
