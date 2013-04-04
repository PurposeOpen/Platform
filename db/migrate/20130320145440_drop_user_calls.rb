class DropUserCalls < ActiveRecord::Migration
  def up
  	drop_table :user_calls
  end

  def down
  	create_table "user_calls", :force => true do |t|
	    t.integer  "page_id"
	    t.integer  "content_module_id"
	    t.integer  "user_id"
	    t.integer  "email_id"
	    t.datetime "created_at",        :null => false
	    t.datetime "updated_at",        :null => false
	    t.text     "targets"
	  end
  end
end
