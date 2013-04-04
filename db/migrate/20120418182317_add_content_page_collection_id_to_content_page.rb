class AddContentPageCollectionIdToContentPage < ActiveRecord::Migration
  def change
    add_column :content_pages, :content_page_collection_id, :integer
  end
end
