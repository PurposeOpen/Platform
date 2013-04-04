class ChangeMovementUrLsToASingleUrl < ActiveRecord::Migration
  def change
    rename_column :movements, :urls, :url
    change_column :movements, :url, :string
  end
end
