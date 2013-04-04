class UpdateIndexesOnUsersAndUserActivityEvents < ActiveRecord::Migration
  def up
    remove_index "users", :name => "postcode_id_idx"
    remove_index "users", :name => "index_users_on_deleted_at_and_is_member_and_movement_id"
    add_index "users", "deleted_at", :name => "idx_deleted_at"

    remove_index "user_activity_events", :name => "activities_user_id_idx"
    add_index "user_activity_events", ["user_id", "created_at", "content_module_type"], :name => "user_id_created_mod_type"
  end

  def down
    add_index "users", ["deleted_at", "postcode_id"], :name => "postcode_id_idx"
    add_index "users", ["deleted_at", "is_member", "movement_id"], :name => "index_users_on_deleted_at_and_is_member_and_movement_id"
    remove_index "users", :name => "idx_deleted_at"

    add_index "user_activity_events", "user_id", :name => "activities_user_id_idx"
    remove_index "user_activity_events", :name => "user_id_created_mod_type"
  end
end
