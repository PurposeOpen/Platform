class DropCommentsTable < ActiveRecord::Migration
  def up
  	drop_table :comments
  end

  def down
  	create_table "comments", :force => true do |t|
	    t.integer  "commentable_id",   :default => 0
	    t.string   "commentable_type", :default => ""
	    t.string   "title",            :default => ""
	    t.text     "body"
	    t.string   "subject",          :default => ""
	    t.integer  "user_id",          :default => 0,  :null => false
	    t.integer  "parent_id"
	    t.integer  "lft"
	    t.integer  "rgt"
	    t.datetime "created_at",                       :null => false
	    t.datetime "updated_at",                       :null => false
	  end

	  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
	  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"
  end
end
