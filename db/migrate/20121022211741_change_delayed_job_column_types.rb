# Reason:
# https://groups.google.com/forum/?fromgroups=#!topic/delayed_job/H_3izeLszYs
class ChangeDelayedJobColumnTypes < ActiveRecord::Migration
  def self.up
    change_column :delayed_jobs, :last_error, :text
    change_column :delayed_jobs, :handler, :text, :limit => 4294967295
  end

  def self.down
    change_column :delayed_jobs, :last_error, :string
    change_column :delayed_jobs, :handler, :text
  end
end