require 'spec_helper'

describe StatsScheduler do
  describe "#schedule_push_stats" do
    it "should schedule jobs every 10 minutes for the next hour" do
      # Not the best test, but we should be replacing this with Heroku Scheduler add-on anyways

      right_now = Time.zone.now
      Time.zone.stub!(:now).and_return(right_now)
      6.times do |i|
        mocked_job = mock(Delayed::Backend::ActiveRecord::Job)
        UniqueActivityByEmail.should_receive(:delay).with(:run_at => right_now + i*10.minutes).and_return(mocked_job)
        mocked_job.should_receive(:update!)
      end
      StatsScheduler.schedule_push_stats
    end
  end
end
