class AddIndexesForProfanalyzerFlags < ActiveRecord::Migration
  def up
    add_index :users, :name_safe
    add_index :user_activity_events, :comment_safe
  end

  def down
    remove_index :users, :name_safe
    remove_index :user_activity_events, :comment_safe
  end
end
