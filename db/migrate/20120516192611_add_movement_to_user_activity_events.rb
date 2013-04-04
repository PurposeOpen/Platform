class AddMovementToUserActivityEvents < ActiveRecord::Migration
  def change
    add_column :user_activity_events, :movement_id, :int
    add_index :user_activity_events, :movement_id
  end
end
