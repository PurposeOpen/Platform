class AddLanguageIdToContentModule < ActiveRecord::Migration
  def change
    add_column :content_modules, :language_id, :integer
  end
end
