class DropTheme < ActiveRecord::Migration
  def up
  	drop_table :themes
	  remove_column :action_sequences, :theme_id
  end

  def down
  	create_table "themes", :force => true do |t|
	    t.string   "name"
	    t.datetime "created_at",   :null => false
	    t.datetime "updated_at",   :null => false
	    t.string   "display_name"
	  end

	  add_column :action_sequences, :theme_id, :integer
  end
end
