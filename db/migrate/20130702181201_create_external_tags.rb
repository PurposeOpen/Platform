class CreateExternalTags < ActiveRecord::Migration
  def change
    create_table :external_tags do |t|
      t.string :name, null: false
      t.integer :movement_id, null: false

      t.timestamps
    end
    
    add_index :external_tags, :name, unique: true
  end
end
