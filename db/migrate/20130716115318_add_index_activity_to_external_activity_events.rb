class AddIndexActivityToExternalActivityEvents < ActiveRecord::Migration
  def change
    add_index :external_activity_events, :activity
  end
end
