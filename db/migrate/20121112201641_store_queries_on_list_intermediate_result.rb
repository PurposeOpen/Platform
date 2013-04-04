class StoreQueriesOnListIntermediateResult < ActiveRecord::Migration
  def change
    add_column :list_intermediate_results, :queries, :text
  end
end
