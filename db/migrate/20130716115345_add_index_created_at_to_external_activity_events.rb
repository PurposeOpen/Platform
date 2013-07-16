class AddIndexCreatedAtToExternalActivityEvents < ActiveRecord::Migration
  def change
    add_index :external_activity_events, :created_at
  end
end
