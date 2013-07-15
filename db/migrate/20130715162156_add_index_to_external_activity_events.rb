class AddIndexToExternalActivityEvents < ActiveRecord::Migration
  def change
    add_index :external_activity_events, :user_id
    add_index :external_activity_events, :external_action_id
  end
end
