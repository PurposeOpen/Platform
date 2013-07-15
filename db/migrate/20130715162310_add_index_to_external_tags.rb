class AddIndexToExternalTags < ActiveRecord::Migration
  def change
    add_index :external_tags, :movement_id
  end
end
