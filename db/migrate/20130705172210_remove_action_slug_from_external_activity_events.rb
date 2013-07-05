class RemoveActionSlugFromExternalActivityEvents < ActiveRecord::Migration
  def up
    remove_column :external_activity_events, :action_slug
  end
  
  def down
    add_column :external_activity_events, :action_slug, :string
  end
end
