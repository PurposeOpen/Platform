class DropBookmarkedContentModules < ActiveRecord::Migration
  def up
  	drop_table :bookmarked_content_modules
  end

  def down
  	create_table "bookmarked_content_modules", :force => true do |t|
	    t.integer  "content_module_id",               :null => false
	    t.string   "name",              :limit => 64, :null => false
	    t.datetime "created_at",                      :null => false
	    t.datetime "updated_at",                      :null => false
	  end
  end
end
