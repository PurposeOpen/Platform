class AddSavedIntermediateResultToLists < ActiveRecord::Migration
  def up
    add_column :lists, :saved_intermediate_result_id, :integer
    add_foreign_key :lists, :list_intermediate_results, column: :saved_intermediate_result_id, dependent: :nullify
    execute("UPDATE lists l SET saved_intermediate_result_id=(SELECT MAX(id) FROM list_intermediate_results WHERE list_id=l.id)")
  end

  def down
    remove_foreign_key :lists,  :saved_intermediate_result
    remove_column :lists, :saved_intermediate_result_id
  end
end
