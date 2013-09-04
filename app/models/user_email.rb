# == Schema Information
#
# Table name: user_emails
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  content_module_id :integer          not null
#  subject           :string(255)      not null
#  body              :text             default(""), not null
#  targets           :text             default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  page_id           :integer          not null
#  email_id          :integer
#  cc_me             :boolean
#

class UserEmail < ActiveRecord::Base  
  include ActsAsUserResponse

  belongs_to :page

  after_create :create_activity_event
  
  validates_presence_of :subject
  validates_presence_of :body
  validates_presence_of :targets, :message => "should be selected"
  
  def async_send!
    Emailer.target_email(page.movement, user.email, user.email, subject, body).deliver if cc_me
    Emailer.target_email(page.movement, targets, user.email, subject, body).deliver
    true
  end

  def send!
    self.save
    Resque.enqueue(Jobs::SendUserEmail, self.id)
  end

  def comment; nil; end
end
