class AddReasonToUserActivityEvent < ActiveRecord::Migration
  def change
    add_column :user_activity_events, :reason, :string
  end
end
