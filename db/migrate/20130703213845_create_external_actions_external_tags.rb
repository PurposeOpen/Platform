class CreateExternalActionsExternalTags < ActiveRecord::Migration
  def change
    create_table :external_actions_external_tags do |t|
      t.integer :external_action_id, null: false
      t.integer :external_tag_id, null: false
    end
  end
end
