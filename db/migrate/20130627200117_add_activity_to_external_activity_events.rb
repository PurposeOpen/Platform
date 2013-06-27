class AddActivityToExternalActivityEvents < ActiveRecord::Migration
  def change
    add_column :external_activity_events, :activity, :string
  end
end
