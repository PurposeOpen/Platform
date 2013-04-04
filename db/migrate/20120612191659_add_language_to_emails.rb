class AddLanguageToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :language_id, :integer
  end
end
