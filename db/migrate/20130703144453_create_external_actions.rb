class CreateExternalActions < ActiveRecord::Migration
  def change
    create_table :external_actions do |t|
      t.integer :movement_id, null: false
      t.string :source, null: false
      t.string :partner
      t.string :action_slug, null: false
      t.string :unique_action_slug, null: false
      t.string :action_language_iso, null: false

      t.timestamps
    end
    
    add_index :external_actions, :unique_action_slug, unique: true
  end
end
