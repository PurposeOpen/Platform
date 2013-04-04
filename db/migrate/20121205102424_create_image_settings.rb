class CreateImageSettings < ActiveRecord::Migration
  def change
    create_table :image_settings, :id => false do |t|
      t.integer :carousel_image_height
      t.integer :carousel_image_width
      t.integer :carousel_image_dpi
      t.integer :action_page_image_height
      t.integer :action_page_image_width
      t.integer :action_page_image_dpi
      t.integer :featured_action_image_height
      t.integer :featured_action_image_width
      t.integer :featured_action_image_dpi
      t.integer :facebook_image_height
      t.integer :facebook_image_width
      t.integer :facebook_image_dpi
      t.references :movement

      t.timestamps
    end
    add_index :image_settings, :movement_id, :unique => true
    add_foreign_key :image_settings, :movements
  end
end
