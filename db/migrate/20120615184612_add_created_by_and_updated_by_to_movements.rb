class AddCreatedByAndUpdatedByToMovements < ActiveRecord::Migration
  def change
    add_column :movements, :created_by, :string
    add_column :movements, :updated_by, :string
  end
end
