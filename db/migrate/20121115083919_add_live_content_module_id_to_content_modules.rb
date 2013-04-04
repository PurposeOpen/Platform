class AddLiveContentModuleIdToContentModules < ActiveRecord::Migration
  def change
    add_column "content_modules", "live_content_module_id", "integer"
    add_foreign_key "content_modules", "content_modules", :name => "live_content_module_id_fk", :column => "live_content_module_id"
  end
end
