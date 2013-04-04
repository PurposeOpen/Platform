class DropEvents < ActiveRecord::Migration
  def up
  	drop_table :events
  	drop_table :events_attendees
  end

  def down
  	create_table "events", :force => true do |t|
	    t.datetime "created_at",                                                              :null => false
	    t.datetime "updated_at",                                                              :null => false
	    t.string   "name"
	    t.date     "date"
	    t.integer  "time"
	    t.string   "address"
	    t.integer  "host_id"
	    t.text     "host_notes"
	    t.datetime "deleted_at"
	    t.integer  "get_together_id"
	    t.integer  "capacity"
	    t.string   "phone"
	    t.boolean  "confirmed",                                            :default => false
	    t.string   "confirmation_code"
	    t.datetime "confirmed_at"
	    t.datetime "canceled_at"
	    t.string   "postcode"
	    t.string   "street"
	    t.string   "suburb"
	    t.decimal  "address_latitude",     :precision => 15, :scale => 12
	    t.decimal  "address_longitude",    :precision => 15, :scale => 12
	    t.decimal  "suburb_latitude",      :precision => 15, :scale => 12
	    t.decimal  "suburb_longitude",     :precision => 15, :scale => 12
	    t.boolean  "terms_and_conditions",                                 :default => false
	    t.boolean  "is_public"
	    t.string   "slug"
	  end

	  add_index "events", ["slug"], :name => "index_events_on_slug"

	  create_table "events_attendees", :id => false, :force => true do |t|
	    t.integer "event_id",    :null => false
	    t.integer "attendee_id", :null => false
	  end
  end
end
