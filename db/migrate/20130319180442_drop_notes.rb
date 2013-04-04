class DropNotes < ActiveRecord::Migration
  def up
  	drop_table :notes
  end

  def down
  	create_table "notes", :force => true do |t|
	    t.text     "value"
	    t.string   "created_by"
	    t.string   "updated_by"
	    t.datetime "created_at", :null => false
	    t.datetime "updated_at", :null => false
	  end
  end
end
