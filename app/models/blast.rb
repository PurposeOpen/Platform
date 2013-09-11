# == Schema Information
#
# Table name: blasts
#
#  id             :integer          not null, primary key
#  push_id        :integer
#  name           :string(255)
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  delayed_job_id :integer
#  failed_job_ids :string(255)
#

class Blast < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :push
  has_many :emails, dependent: :destroy
  has_one :list, dependent: :destroy

  LIMIT_MEMBERS = 'limit_members'
  ALL_MEMBERS = 'all_members'

  validates_length_of :name, maximum: 64, minimum: 3

  delegate :movement, :campaign, to: :push, allow_nil: true
  delegate :proofed_emails, to: :emails

  after_save ->{campaign.touch}

  def send_proofed_emails!(options={})
    emails = (options[:email_ids] ? proofed_emails.for_ids(options[:email_ids]).all : proofed_emails.all).reject { |e| e.sent }
    segment_user_ids_per_job(emails, options[:limit], options[:run_at_utc])
  end

  def segment_user_ids_per_job(emails_to_send, limit, run_at_utc)
    emails_by_language = emails_to_send.group_by(&:language)
    emails_by_language.each do |language, emails|
      no_jobs = emails.size
      emails.each_with_index do |email, current_job_index|
        email.enqueue_job(no_jobs, current_job_index, limit, run_at_utc)
      end
    end
  end

  private :segment_user_ids_per_job

  def has_pending_jobs?
    proofed_emails.pending_emails.exists?
  end

  def has_failed_jobs?
    !failed_job_ids.blank?
  end

  def list_cuttable?
    emails.pending_emails.empty? && emails.sent_emails.empty?
  end

  def latest_sent_user_count
    @latest_sent_user_count ||= UniqueActivityByEmail.where(activity: 'email_sent', email_id: proofed_emails.pluck(:id)).sum(:total_count)
  end

  def latest_unsent_user_count
    user_count = (list && list.user_count || 0) - latest_sent_user_count
    if user_count > 0
      user_count
    else
      0
    end
  end

  def cancel
    return false if self.delayed_job_id.blank?
    Delayed::Job.where(id: self.delayed_job_id, locked_at: nil).destroy_all
    self.update_attribute(:delayed_job_id, nil)
    true
  rescue Exception => e
    Rails.logger.error "Tried deleting jobs with ids: #{self.delayed_job_id} - Original exception: #{e.message}"
    false
  end

  def remaining_time_for_existing_jobs
    job_ids = [self.delayed_job_id]
    jobs = Delayed::Job.where(id: job_ids).order("run_at desc").limit(1)
    return 0 if jobs.blank?
    seconds = jobs.first.run_at - Time.now
    seconds < 0 ? 0 : (seconds * 100).round.to_f / 100
  end

end
