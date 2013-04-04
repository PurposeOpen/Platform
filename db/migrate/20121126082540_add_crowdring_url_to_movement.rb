class AddCrowdringUrlToMovement < ActiveRecord::Migration
  def change
    add_column :movements, :crowdring_url, :string
  end
end
