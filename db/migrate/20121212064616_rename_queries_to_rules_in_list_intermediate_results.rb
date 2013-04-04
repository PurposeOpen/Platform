class RenameQueriesToRulesInListIntermediateResults < ActiveRecord::Migration
  def change
    rename_column :list_intermediate_results, :queries, :rules
  end
end
