class AddIndexToPages < ActiveRecord::Migration
  def up
  	add_index :pages, [:live_page_id, :deleted_at, :type, :action_sequence_id, :position], :name => "pages_index_live_lpid_type_asid_pos"
  end

  def down
  	remove_index :pages, [:live_page_id, :deleted_at, :type, :action_sequence_id, :position]
  end
end
