class AddEmailIdIndexToPushTables < ActiveRecord::Migration
  def up
    %w{push_spammed_emails push_clicked_emails push_viewed_emails push_sent_emails}.each do |table|
      add_index table, [:movement_id, :email_id], name: :idx_emails
      add_index table, [:movement_id, :push_id], name: :idx_pushes
    end

    add_index :users, [:movement_id, :language_id]
  end

  def down
    %w{push_spammed_emails push_clicked_emails push_viewed_emails push_sent_emails}.each do |table|
      remove_index table, :idx_emails
      remove_index table, :idx_pushes
    end

    remove_index :users, [:movement_id, :language_id]
  end
end
