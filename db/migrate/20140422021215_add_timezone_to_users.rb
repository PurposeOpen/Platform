class AddTimezoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string
  end
end
