class DropEmailActivityByPushIdTables < ActiveRecord::Migration
  def up
    tables.grep(/push_(\d+)/).each { |t| drop_table t }
    execute "DROP TABLE IF EXISTS push_sent_emails_backup;"
  end

  def down
  end
end
