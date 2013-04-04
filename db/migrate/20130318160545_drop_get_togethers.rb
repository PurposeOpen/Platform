class DropGetTogethers < ActiveRecord::Migration
  def up
  	remove_column :user_activity_events, :get_together_event_id
  	drop_table :get_togethers
  	drop_table :get_together_content_module_links
  end

  def down
  	add_column :user_activity_events, :get_together_event_id, :integer

  	create_table "get_together_content_module_links", :force => true do |t|
	    t.integer  "content_module_id"
	    t.integer  "get_together_id"
	    t.datetime "created_at",        :null => false
	    t.datetime "updated_at",        :null => false
	  end

	  create_table "get_togethers", :force => true do |t|
	    t.string   "name"
	    t.integer  "campaign_id"
	    t.date     "from_date"
	    t.date     "to_date"
	    t.date     "recommended_date"
	    t.integer  "from_time"
	    t.integer  "to_time"
	    t.integer  "recommended_time"
	    t.datetime "deleted_at"
	    t.datetime "created_at",              :null => false
	    t.datetime "updated_at",              :null => false
	    t.string   "description"
	    t.text     "host_greeting_email"
	    t.text     "attendee_greeting_email"
	    t.text     "options"
	    t.boolean  "is_closed"
	    t.string   "slug"
	  end

	  add_index "get_togethers", ["slug"], :name => "index_get_togethers_on_slug"
  end
end
