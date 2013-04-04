class DropTagsFromUsers < ActiveRecord::Migration
  def up
  	remove_column :users, :tags
  end

  def down
  	add_column :users, :tags, :string, :default => "", :null => false
  end
end
