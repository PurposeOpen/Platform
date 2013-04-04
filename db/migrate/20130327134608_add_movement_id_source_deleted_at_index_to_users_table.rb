class AddMovementIdSourceDeletedAtIndexToUsersTable < ActiveRecord::Migration
  def up
    add_index :users, [:movement_id, :source, :deleted_at], name: :index_users_on_movement_id_and_source_and_deleted_at
  end

  def down
    remove_index :users, name: :index_users_on_movement_id_and_source_and_deleted_at
  end
end
