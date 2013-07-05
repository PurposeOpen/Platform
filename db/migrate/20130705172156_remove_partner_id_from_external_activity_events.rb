class RemovePartnerIdFromExternalActivityEvents < ActiveRecord::Migration
  def up
    remove_column :external_activity_events, :partner
  end

  def down
    add_column :external_activity_events, :partner, :string
  end
end
