require 'delayed_job'

class DelayedJobLoggerPlugin < Delayed::Plugin

  callbacks do |lifecycle|
    lifecycle.around(:invoke_job) do |job, *args, &block|
        # Forward the call to the next callback in the callback chain
        block.call(job, *args)
        if job.queue == (ENV['LIST_CUTTER_BLASTER_QUEUE'] || 'list_cutter_blaster')
          Rails.logger.debug("List cutter job. Created at: #{job.created_at}. Run at: #{job.run_at}. Handler #{job.handler}")
          #target_object = YAML::load(job.handler)
          #if target_object.kind_of?(BlastJob)
          #  Rails.logger.debug("List cutter job. Created at: #{job.created_at}. Run at: #{job.run_at}. Handler #{job.handler}")
          #end
        end
    end

  end

end