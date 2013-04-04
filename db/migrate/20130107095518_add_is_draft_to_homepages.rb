class AddIsDraftToHomepages < ActiveRecord::Migration
  def change
    add_column :homepages, :draft, :boolean, :default => false
  end
end
