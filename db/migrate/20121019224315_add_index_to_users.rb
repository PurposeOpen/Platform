class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index 'users', ['deleted_at', 'is_member', 'movement_id']
  end
end
