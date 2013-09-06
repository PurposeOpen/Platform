class ChangeHomepageJoinFieldsToText < ActiveRecord::Migration
  def up
    change_column :homepage_contents, :join_headline, :text
    change_column :homepage_contents, :join_message,  :text
  end

  def down
    change_column :homepage_contents, :join_headline, :string
    change_column :homepage_contents, :join_message,  :string
  end
end
