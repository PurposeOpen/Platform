class CreateFeaturedContentModules < ActiveRecord::Migration
  def change
    create_table :featured_content_modules do |t|
      t.integer :featured_content_collection_id
      t.integer :language_id
      t.string :title
      t.string :image
      t.text :description
      t.string :link
      t.string :button_text
      t.datetime :date

      t.timestamps
    end
  end
end
