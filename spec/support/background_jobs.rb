module BackgroundJobs
  def run_background_jobs_immediately
    inline = Resque.inline
    Resque.inline = true
    yield
    Resque.inline = inline
  end
end