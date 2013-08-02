class AddIndexToContentModuleLinks < ActiveRecord::Migration
  def up
  	add_index :content_module_links, [:id,:page_id,:content_module_id,:position,:layout_container], :name => "content_module_links_pid_pos_layout"
  end

  def down
  	remove_index :content_module_links, [:id,:page_id,:content_module_id,:position,:layout_container]
  end
end
