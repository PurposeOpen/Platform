class StatsScheduler < ActiveRecord::Base
  def self.schedule_push_stats
    now = Time.zone.now
    6.times do
      UniqueActivityByEmail.delay(:run_at=>now).update!
      now += 10.minutes
    end
  end
end
