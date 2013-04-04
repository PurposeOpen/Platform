require 'delayed_job'

Delayed::Worker.delay_jobs = false