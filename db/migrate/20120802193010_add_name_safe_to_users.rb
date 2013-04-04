class AddNameSafeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name_safe, :boolean
  end
end
