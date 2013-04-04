class AddPermanentlyUnsubscribedToUser < ActiveRecord::Migration
  def change
    add_column :users, :permanently_unsubscribed, :boolean
  end
end
