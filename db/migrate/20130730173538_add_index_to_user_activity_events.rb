class AddIndexToUserActivityEvents < ActiveRecord::Migration
  def up
  	add_index :user_activity_events, [:activity, :page_id]
  end

  def down
  	remove_index :user_activity_events, [:activity, :page_id]
  end
end
