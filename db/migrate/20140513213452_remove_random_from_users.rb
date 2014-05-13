class RemoveRandomFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :random
  end

  def down
    add_column :users, :random, :float
  end
end
