class AddFollowLinksToHomepage < ActiveRecord::Migration
  def change
    add_column :homepages, :follow_links, :text
  end
end
