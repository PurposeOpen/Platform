class AddCommentToUserActivityEvents < ActiveRecord::Migration
  def change
    add_column :user_activity_events, :comment, :string

  end
end
