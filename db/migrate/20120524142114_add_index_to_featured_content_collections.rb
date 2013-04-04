class AddIndexToFeaturedContentCollections < ActiveRecord::Migration
  def change
    add_index :featured_content_collections, [:featurable_id, :featurable_type], :name => "index_feat_cont_coll_polymorphic_id_and_type"
  end
end
