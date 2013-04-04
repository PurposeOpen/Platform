class RenamePageSequenceToActionSequence < ActiveRecord::Migration
  def up
    rename_table :page_sequences, :action_sequences
    rename_column :pages, :page_sequence_id, :action_sequence_id
    rename_column :user_activity_events, :page_sequence_id, :action_sequence_id
  end

  def down
    rename_table :action_sequences, :page_sequences
    rename_column :pages, :action_sequence_id, :page_sequence_id
    rename_column :user_activity_events, :action_sequence_id, :page_sequence_id
  end
end
