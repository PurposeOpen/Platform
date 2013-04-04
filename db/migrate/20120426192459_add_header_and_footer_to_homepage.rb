class AddHeaderAndFooterToHomepage < ActiveRecord::Migration
  def change
    add_column :homepages, :header_navbar, :text
    add_column :homepages, :footer_navbar, :text
  end
end
