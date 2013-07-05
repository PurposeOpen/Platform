class AddExternalActionIdToExternalActivityEvent < ActiveRecord::Migration
  def change
    add_column :external_activity_events, :external_action_id, :integer
  end
end
