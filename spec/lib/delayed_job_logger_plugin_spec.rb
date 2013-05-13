require 'spec_helper'

describe DelayedJobLoggerPlugin do

  before { Delayed::Worker.delay_jobs = true }
  after { Delayed::Worker.delay_jobs = false }

  it 'should log every successful job in the list cutter queue' do
    object_to_delay = ObjectToDelay.new
    object_to_delay.delay(:queue => QueueConfigs::LIST_CUTTER_BLASTER_QUEUE).method_that_never_fails
    Delayed::Worker.exit_on_complete = true
    worker = Delayed::Worker.new

    Rails.logger.should_receive(:debug).with(/List cutter job/)

    worker.start
  end

  it 'should not log unsuccessful jobs in the list cutter queue' do
    object_to_delay = ObjectToDelay.new
    object_to_delay.delay(:queue => QueueConfigs::LIST_CUTTER_BLASTER_QUEUE).method_that_always_fails
    Delayed::Worker.exit_on_complete = true
    worker = Delayed::Worker.new

    Rails.logger.should_not_receive(:debug).with("List cutter job: --- !ruby/object:Delayed::PerformableMethod\nobject: !ruby/object:ObjectToDelay\n  counter: 0\nmethod_name: :method_that_never_fails\nargs: []\n")

    worker.start
  end

  it 'should not log jobs in queues other than the list cutter' do
    object_to_delay = ObjectToDelay.new
    object_to_delay.delay(:queue => 'default').method_that_never_fails
    Delayed::Worker.exit_on_complete = true
    worker = Delayed::Worker.new

    Rails.logger.should_not_receive(:debug).with("List cutter job: --- !ruby/object:Delayed::PerformableMethod\nobject: !ruby/object:ObjectToDelay\n  counter: 0\nmethod_name: :method_that_never_fails\nargs: []\n")

    worker.start
  end


end