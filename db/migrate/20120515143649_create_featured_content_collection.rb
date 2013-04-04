class CreateFeaturedContentCollection < ActiveRecord::Migration
  def change
    create_table :featured_content_collections do |t|
    	t.string     :name
      t.references :featurable, :polymorphic => true
      t.timestamps
    end
  end
end
