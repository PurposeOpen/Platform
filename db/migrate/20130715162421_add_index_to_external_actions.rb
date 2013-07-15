class AddIndexToExternalActions < ActiveRecord::Migration
  def change
    add_index :external_actions, :movement_id
    add_index :external_actions, :source
  end
end
