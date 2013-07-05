class RemoveMovementIdFromExternalActivityEvents < ActiveRecord::Migration
  def up
    remove_column :external_activity_events, :movement_id
  end

  def down
    add_column :external_activity_events, :movement_id, :integer
  end
end
