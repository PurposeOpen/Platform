class AddIndexDeletedAtMovementIdIsMemberOnUsers < ActiveRecord::Migration
  def up
    add_index :users, [:deleted_at, :movement_id, :is_member]
  end

  def down
    remove_index :users, [:deleted_at, :movement_id, :is_member]
  end
end
