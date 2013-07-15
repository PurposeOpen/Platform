class ScopeUniqueIndexOnExternalTagsToMovementId < ActiveRecord::Migration
  def up
    remove_index :external_tags, :name
    add_index :external_tags, [:movement_id, :name], :unique=>true
  end

  def down
    add_index :external_tags, :name, unique: true
    remove_index :external_tags, [:movement_id, :name]
  end
end
