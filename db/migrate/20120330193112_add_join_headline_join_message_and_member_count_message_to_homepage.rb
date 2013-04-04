class AddJoinHeadlineJoinMessageAndMemberCountMessageToHomepage < ActiveRecord::Migration
  def up
    add_column :homepages, :join_headline, :string
    add_column :homepages, :join_message, :string
    add_column :homepages, :member_count_message, :string
  end

  def down
    remove_column :homepages, :join_headline
    remove_column :homepages, :join_message
    remove_column :homepages, :member_count_message
  end
end
