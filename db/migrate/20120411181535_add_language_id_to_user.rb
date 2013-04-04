class AddLanguageIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :language_id, :integer
  end
end
