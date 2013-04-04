class ChangeFeaturedContentModuleTitleToText < ActiveRecord::Migration
  def up
    change_column :featured_content_modules, :title, :text
  end

  def down
    change_column :featured_content_modules, :title, :string
  end
end
