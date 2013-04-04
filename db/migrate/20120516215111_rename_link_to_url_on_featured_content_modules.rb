class RenameLinkToUrlOnFeaturedContentModules < ActiveRecord::Migration
  def up
    rename_column :featured_content_modules, :link, :url
  end

  def down
    rename_column :featured_content_modules, :url, :link
  end
end
