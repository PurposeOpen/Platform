class AddCommentSafeToUserActivityEvents < ActiveRecord::Migration
  def change
    add_column :user_activity_events, :comment_safe, :boolean
  end
end
