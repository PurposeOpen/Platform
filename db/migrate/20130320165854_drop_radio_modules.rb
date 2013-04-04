class DropRadioModules < ActiveRecord::Migration
  def up
  	drop_table :radio_shows
  	drop_table :radio_stations
  end

  def down
  	create_table "radio_shows", :force => true do |t|
	    t.string   "name"
	    t.string   "presenter"
	    t.time     "from_time"
	    t.time     "to_time"
	    t.string   "website"
	    t.string   "show_type"
	    t.integer  "radio_station_id"
	    t.datetime "created_at",       :null => false
	    t.datetime "updated_at",       :null => false
	  end

	  create_table "radio_stations", :force => true do |t|
	    t.string   "name"
	    t.string   "state"
	    t.string   "phone"
	    t.string   "sms"
	    t.string   "fax"
	    t.string   "air"
	    t.decimal  "latitude",         :precision => 15, :scale => 12
	    t.decimal  "longitude",        :precision => 15, :scale => 12
	    t.float    "broadcast_radius"
	    t.datetime "created_at",                                       :null => false
	    t.datetime "updated_at",                                       :null => false
	  end
  end
end
