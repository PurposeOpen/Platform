class AddIndexToExternalActionsExternalTags < ActiveRecord::Migration
  def change
    add_index :external_actions_external_tags, :external_action_id
    add_index :external_actions_external_tags, :external_tag_id
  end
end
