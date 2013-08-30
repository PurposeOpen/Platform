# == Schema Information
#
# Table name: emails
#
#  id                :integer          not null, primary key
#  blast_id          :integer
#  name              :string(255)
#  sent_to_users_ids :text
#  subject           :string(255)
#  body              :text
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  test_sent_at      :datetime
#  delayed_job_id    :integer
#  language_id       :integer
#  from              :string(255)
#  reply_to          :string(255)
#  alternate_key_a   :string(25)
#  alternate_key_b   :string(25)
#  sent              :boolean
#  sent_at           :datetime
#

class Email < ActiveRecord::Base
  include HasLinksWithEmailTrackingHash
  include EmailBodyConverter
  include QuickGoable

  acts_as_paranoid
  belongs_to :blast
  belongs_to :language
  belongs_to :delayed_job, :class_name => '::Delayed::Job'

  validates_presence_of :blast, :name, :from, :subject, :body, :reply_to, :language_id
  validates :from, :email_format => true, :unless => ->{from.blank?}

  delegate :push, :to => :blast
  delegate :campaign, :to => :push

  after_save ->{campaign.touch}
  after_save ->{Rails.cache.delete("/grouped_select_options_email/#{campaign.movement_id}")}

  scope :proofed_emails, lambda { where("test_sent_at IS NOT ?", nil) }
  scope :pending_emails, lambda { where("delayed_job_id IS NOT NULL") }
  scope :schedulable_emails, lambda { where("delayed_job_id IS NULL and (sent IS NULL OR sent = false)") }
  scope :sent_emails, lambda { where(:sent => true) }
  scope :for_ids, lambda { |email_ids| where(id: email_ids) }
  scope :for_movement_id, lambda { |movement_id| joins(:blast => {:push => :campaign}).where('campaigns.movement_id' => movement_id) }

  DEFAULT_TEST_EMAIL_RECIPIENT = ENV['DEFAULT_TEST_EMAIL_RECIPIENT'] || 'test@platform.youdomain.org'

  def send_test!(recipients=[])
    recipients << DEFAULT_TEST_EMAIL_RECIPIENT
    self.touch(:test_sent_at)
    SendgridMailer.blast_email(self, {:recipients => recipients, :test => true}).deliver
  end

  def self.page_options(movement_id)
    Email.for_movement_id(movement_id).order("emails.updated_at desc").collect { |email| [email.name, email.id] }
  end

  handle_asynchronously(:send_test!) unless Rails.env.test?

  def html_body
    add_tracking_hash_to_html_links(self.body)
  end
  
  def sent_at    
    if sent && self[:sent_at].blank?
      self[:updated_at]
    else
      self[:sent_at]
    end
  end

  def display_name
    "#{self.name} (#{language.name})"
  end

  def plain_text_body
    add_tracking_hash_to_plain_text_links(convert_html_to_plain(self.body))
  end

  def footer
    movement.footer_for_language(self.language.iso_code)
  end

  def movement
    push.campaign.movement
  end

  def movement=(new_movement)
    push.campaign.movement = new_movement
  end

  def deliver_blast_in_batches(user_ids, batch_size=1000)
    logger.debug "LDEBUG: Total user ids for email #{self.id} - #{user_ids.count}"
    user_ids.each_slice(batch_size).with_index do |slice,i|
      begin
        recipients = User.select(:email).where(:id => slice).order(:email).map(&:email)
        logger.debug "LDEBUG: User ids for email #{self.id} slice # #{i} - #{slice.count}. Recipients: #{recipients.count}"
        
        if i==0 && AppConstants.blast_cc_email.present?
          recipients << AppConstants.blast_cc_email
        end 
        email_sent = SendgridMailer.blast_email(self, :recipients => recipients).deliver unless sendgrid_interation_is_disabled?
        EmailRecipientDetail.create_with(self, email_sent).save
        self.push.batch_create_sent_activity_event!(slice, self)
      rescue Exception => e
        logger.error e.inspect
        self.update_attribute(:delayed_job_id, nil)
        PushLog.log_exception(self, slice, e)
      end
    end
  end

  def sendgrid_interation_is_disabled?
    check = (ENV['DISABLE_SENDGRID_INTERACTION'] == "true")
    Rails.logger.debug "LDEBUG: sendgrid_interation_is_disabled? #{check}"
    return check
  end

  def proofed?
    test_sent_at.present?
  end

  def schedulable?
    delayed_job.nil? && (sent.nil? || !sent)
  end

  def clear_test_timestamp!
    self.test_sent_at = nil
    self.save
  end

  def enqueue_job(number_of_jobs, current_job_index, limit, run_at)
    blast_job = BlastJob.new(
        :no_jobs => number_of_jobs,
        :current_job_id => current_job_index,
        :list => blast.list,
        :email => self,
        :limit => limit
    )

    scheduled_time_in_app_time_zone = run_at.in_time_zone(Time.zone)
    job_handle = Delayed::Job.enqueue(blast_job, :run_at => scheduled_time_in_app_time_zone,
                                                 :queue => QueueConfigs::LIST_CUTTER_BLASTER_QUEUE)
    update_attribute(:delayed_job_id, job_handle.id)
  end

  def remaining_time_to_send
    delayed_job_id ? (delayed_job.run_at.utc - Time.now.utc).round : 0
  end

  def cancel_schedule
    return false unless delayed_job_id
    Delayed::Job.where(:id => delayed_job_id, :locked_at => nil).destroy_all
    self.update_attribute(:delayed_job_id, nil)
    true
  rescue Exception => e
    Rails.logger.error "Tried deleting jobs with ids: #{self.delayed_job_id} - Original exception: #{e.message}"
    false
  end
end
