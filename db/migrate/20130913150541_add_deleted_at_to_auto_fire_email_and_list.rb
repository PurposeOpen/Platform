class AddDeletedAtToAutoFireEmailAndList < ActiveRecord::Migration
  def change
    add_column :autofire_emails, :deleted_at, :datetime
    add_column :lists,           :deleted_at, :datetime
  end
end
