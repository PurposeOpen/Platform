class AddLngToUser < ActiveRecord::Migration
  def change
    add_column :users, :lng, :string
  end
end
