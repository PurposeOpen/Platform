class AddTimeZoneToMovements < ActiveRecord::Migration
  def change
    add_column :movements, :time_zone, :string
  end
end
