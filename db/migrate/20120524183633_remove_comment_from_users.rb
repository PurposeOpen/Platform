class RemoveCommentFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :comment
  end

  def down
    add_column :users, :comment, :string
  end
end
