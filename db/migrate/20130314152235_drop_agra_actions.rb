class DropAgraActions < ActiveRecord::Migration
  def up
  	drop_table :agra_actions
  end

  def down
  	create_table "agra_actions", :force => true do |t|
	    t.integer  "user_id"
	    t.string   "slug"
	    t.string   "role"
	    t.datetime "created_at", :null => false
	    t.datetime "updated_at", :null => false
	  end
  end
end
