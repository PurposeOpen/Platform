class CreateIndexForContentModuleIdInUserActivityEvents < ActiveRecord::Migration
  def change
    add_index :user_activity_events, :content_module_id
  end
end
