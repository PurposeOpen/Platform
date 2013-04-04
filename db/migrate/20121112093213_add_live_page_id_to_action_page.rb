class AddLivePageIdToActionPage < ActiveRecord::Migration
  def change
    add_column "pages", "live_page_id", "integer"
    add_foreign_key "pages", "pages", :name => "live_page_id_fk", :column => "live_page_id"
  end
end
