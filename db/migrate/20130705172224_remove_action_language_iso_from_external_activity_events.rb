class RemoveActionLanguageIsoFromExternalActivityEvents < ActiveRecord::Migration
  def up
    remove_column :external_activity_events, :action_language_iso
  end

  def down
    add_column :external_activity_events, :action_language_iso, :string, limit: 2
  end
end
