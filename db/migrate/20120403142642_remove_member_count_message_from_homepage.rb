class RemoveMemberCountMessageFromHomepage < ActiveRecord::Migration
  def up
    remove_column :homepages, :member_count_message
  end

  def down
    add_column :homepages, :member_count_message, :string
  end
end
