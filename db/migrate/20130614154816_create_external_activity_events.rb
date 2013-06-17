class CreateExternalActivityEvents < ActiveRecord::Migration
  def change
    create_table :external_activity_events do |t|
      t.string :source
      t.integer :movement_id
      t.string :partner
      t.string :action_slug
      t.string :action_language_iso, :limit => 2
      t.string :role
      t.integer :user_id

      t.timestamps
    end
  end
end
