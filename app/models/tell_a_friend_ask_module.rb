# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

class TellAFriendAskModule < ContentModule
  TWITTER_MAXIMUM = 125

  option_fields :email_body, :email_subject, :tweet_text

  after_initialize :defaults

  validates_length_of :email_subject, :minimum => 2, :maximum => 256
  validates_length_of :email_body, :minimum => 10
  validates_length_of :tweet_text, :minimum => 2, :maximum => TWITTER_MAXIMUM
  validates_length_of :title, :maximum => 128, :minimum => 3

  placeable_in SIDEBAR

  def take_action
    return true
  end

  private

  def defaults
    self.title = "Tell your friends!" unless self.title
    self.content = "Your friends would probably like to check this out, why don't you share it with them?" unless self.content
    self.email_subject = "Check out this campaign" unless self.email_subject
    self.email_body = "Why don't you check out this?" unless self.email_body
    self.tweet_text = "Why don't you check out this?" unless self.tweet_text
    self.public_activity_stream_template = "{NAME|A member}, {COUNTRY|} [{HEADER}]" unless self.public_activity_stream_template
  end

end
