class RemovePublicStreamHtmlFromActivityEvents < ActiveRecord::Migration
  def change
    remove_column :user_activity_events, :public_stream_html
  end
end
