class AddIndexesToUserActivityEvents < ActiveRecord::Migration

  def ignore_index_errors(message_regex, &block)
    begin
      yield
    rescue => e
      puts e.message
      raise unless e.message =~ message_regex
    end
  end

  def up
    ignore_index_errors(/Index name 'idx_uae_created_at' on table 'user_activity_events' already exists/i) do
      add_index 'user_activity_events', ['created_at'], :name => 'idx_uae_created_at'
    end

    ignore_index_errors(/Index name 'idx_uae_comment' on table 'user_activity_events' already exists/i) do
      add_index 'user_activity_events', ['comment'], :name => 'idx_uae_comment'
    end

    ignore_index_errors(/Index name 'idx_uae_action_seq_id' on table 'user_activity_events' already exists/i) do
      add_index 'user_activity_events', ['action_sequence_id'], :name => 'idx_uae_action_seq_id'
    end

    ignore_index_errors(/Index name 'activity' on table 'user_activity_events' already exists/i) do
      add_index 'user_activity_events', ['activity', 'page_id'], :name => 'activity'
    end
  end

  def down
    remove_index 'user_activity_events', 'idx_uae_created_at'
    remove_index 'user_activity_events', 'idx_uae_comment'
    remove_index 'user_activity_events', 'idx_uae_action_seq_id'
    remove_index 'user_activity_events', 'activity'
  end
end
