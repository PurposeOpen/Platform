class BlastJob
  attr_reader :options, :email, :list
  def initialize(options)
    @options = options
    @email = options.delete(:email)
    @list = options.delete(:list)
  end

  def perform
    user_ids = list.filter_by_rules_excluding_users_from_push(email, options)
    list.saved_intermediate_result.update_results!
    email.deliver_blast_in_batches(user_ids)
    email.update_attributes(:sent => true, :delayed_job_id => nil, :sent_at => Time.now.utc)
  rescue Exception => e
    email.update_attribute(:delayed_job_id, nil)
    PushLog.log_exception(email, "N/A", e)
    raise
  end

end

