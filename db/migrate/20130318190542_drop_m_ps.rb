class DropMPs < ActiveRecord::Migration
  def up
  	drop_table :mps
  	drop_table :electorates
  	drop_table :electorates_postcodes
  	drop_table :jurisdictions
  	drop_table :postcodes
  	drop_table :postcodes_regions
  	drop_table :regions
  	drop_table :senators
  	remove_column :users, :postcode_id
  end

  def down
  	create_table "mps", :force => true do |t|
	    t.string   "last_name"
	    t.string   "first_name"
	    t.string   "email"
	    t.string   "courtesy"
	    t.string   "salutation"
	    t.string   "honorific"
	    t.string   "gender"
	    t.string   "parliament_phone"
	    t.string   "parliament_fax"
	    t.string   "office_address"
	    t.string   "office_suburb"
	    t.string   "office_state"
	    t.string   "office_postcode"
	    t.string   "office_fax"
	    t.string   "office_phone"
	    t.string   "office_tollfree"
	    t.string   "titles"
	    t.integer  "party_id"
	    t.integer  "electorate_id"
	    t.datetime "created_at",       :null => false
	    t.datetime "updated_at",       :null => false
	  end

	  create_table "electorates", :force => true do |t|
	    t.string  "name"
	    t.integer "jurisdiction_id"
	  end

	  create_table "electorates_postcodes", :id => false, :force => true do |t|
	    t.integer "electorate_id", :default => 0, :null => false
	    t.integer "postcode_id",   :default => 0, :null => false
	  end

	  create_table "jurisdictions", :force => true do |t|
	    t.string   "name"
	    t.datetime "created_at",                        :null => false
	    t.datetime "updated_at",                        :null => false
	    t.boolean  "upper_house_present"
	    t.string   "code",                :limit => 10
	  end

	  create_table "postcodes", :force => true do |t|
	    t.string   "number"
	    t.string   "suburbs",    :limit => 1024
	    t.string   "state"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.float    "longitude"
	    t.float    "latitude"
	  end

	  create_table "postcodes_regions", :id => false, :force => true do |t|
	    t.integer "region_id"
	    t.integer "postcode_id"
	  end

	  create_table "regions", :force => true do |t|
	    t.string   "name"
	    t.datetime "created_at",      :null => false
	    t.datetime "updated_at",      :null => false
	    t.integer  "jurisdiction_id"
	  end

	  create_table "senators", :force => true do |t|
	    t.string   "last_name"
	    t.string   "first_name"
	    t.string   "email"
	    t.string   "honorific"
	    t.string   "state"
	    t.string   "gender"
	    t.string   "parliament_phone"
	    t.string   "parliament_fax"
	    t.string   "office_address"
	    t.string   "office_suburb"
	    t.string   "office_state"
	    t.string   "office_postcode"
	    t.string   "office_fax"
	    t.string   "office_phone"
	    t.string   "office_tollfree"
	    t.string   "mailing_address"
	    t.string   "mailing_suburb"
	    t.string   "mailing_state"
	    t.string   "mailing_postcode"
	    t.string   "titles"
	    t.integer  "party_id"
	    t.datetime "created_at",       :null => false
	    t.datetime "updated_at",       :null => false
	    t.integer  "region_id"
	  end

	  add_column :users, :postcode_id, :integer
  end
end
