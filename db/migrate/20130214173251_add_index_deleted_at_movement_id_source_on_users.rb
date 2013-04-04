class AddIndexDeletedAtMovementIdSourceOnUsers < ActiveRecord::Migration
  def up
    add_index :users, [:deleted_at, :movement_id, :source]
  end

  def down
    remove_index :users, [:deleted_at, :movement_id, :source]
  end
end
