class DropParty < ActiveRecord::Migration
  def up
  	drop_table :parties
  end

  def down
  	create_table "parties", :force => true do |t|
	    t.string   "name"
	    t.string   "abbreviation"
	    t.datetime "created_at",      :null => false
	    t.datetime "updated_at",      :null => false
	    t.integer  "jurisdiction_id"
	  end
  end
end
