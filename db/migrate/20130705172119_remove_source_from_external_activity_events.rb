class RemoveSourceFromExternalActivityEvents < ActiveRecord::Migration
  def up
    remove_column :external_activity_events, :source
  end
  
  def down
    add_column :external_activity_events, :source, :string
  end
end
