class FeaturedContentCollection < ActiveRecord::Base
  has_many :featured_content_modules
end

class AddPositionToFeaturedContentModules < ActiveRecord::Migration
  def up
    add_column :featured_content_modules, :position, :int
    FeaturedContentCollection.includes(:featured_content_modules).all.each do |collection|
      position = 0
      collection.featured_content_modules.each do |content|
        content.position = position
        content.save(:validate => false)
        position += 1
      end
    end
  end

  def down
    remove_column :featured_content_modules, :position
  end
end
