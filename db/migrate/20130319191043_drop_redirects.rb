class DropRedirects < ActiveRecord::Migration
  def up
  	drop_table :redirects
  end

  def down
  	 create_table "redirects", :force => true do |t|
	    t.string   "alias",      :limit => 128
	    t.string   "target",     :limit => 1024
	    t.datetime "created_at",                 :null => false
	    t.datetime "updated_at",                 :null => false
	  end
  end
end
