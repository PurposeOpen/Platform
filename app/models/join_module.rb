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

class JoinModule < ContentModule
  option_fields :button_text,
      :join_statement,
      :post_join_title,
      :post_join_join_statement,
      :post_join_button_text,
      :post_join_content,
      :custom_fields,
      :comment_label,
      :comment_text,
      :comments_enabled

  option_fields :active, :disabled_title, :disabled_content

  after_initialize :defaults

  warnings do
    validates_length_of :public_activity_stream_template, :maximum => 1024, :minimum => 3, :if => :is_ask?

    validates_length_of :title, :maximum => 128, :minimum => 3, :if => :is_ask?
    validates_length_of :button_text, :minimum => 1, :maximum => 64
    validates_presence_of :join_statement

    validates_length_of :post_join_title, :maximum => 128, :if => :is_ask?
    validates_presence_of :comment_label, :if => :comments_enabled?
    validates_length_of :post_join_button_text, :maximum => 64
    validates_presence_of :disabled_title, :unless => :active?
    validates_presence_of :disabled_content, :unless => :active?
  end

  placeable_in SIDEBAR

  def as_json(options = {})
    json = super

    json.tap do |j|
      if options[:email].present? || options[:member_has_joined].present?
        j['title'] = post_join("title")
        j['content'] = post_join("content")
        j['options']['join_statement'] = post_join("join_statement")
        j['options']['button_text'] = post_join("button_text")
      end
      ['post_join_title', 'post_join_content', 'post_join_join_statement', 'post_join_button_text'].each do |key|
        j['options'].delete(key)
      end
    end
  end

  def take_action(user, action_info, page, email=nil)
    unless user.join_email_sent
      user.update_attributes(:join_email_sent => true)
      send_join_email(user, page.movement)
    end

    return false
  end

  def can_remove_from_page?
    false
  end

  def active?
    active == 'true'
  end

  def comments_enabled?
    ["1", true].include? comments_enabled
  end

  private

  def defaults
    self.button_text ||= "Join"
    self.public_activity_stream_template ||= "{NAME|A member}, {COUNTRY|}<br/> [{HEADER}]"
    self.comments_enabled = true if self.comments_enabled.nil?
    self.active = 'true' unless self.active
  end

  def post_join(field)
    value = self.send "post_join_#{field}"
    value.present? ? value : self.send(field)
  end

  def send_join_email(member, movement)
    join_email = movement.join_emails.find {|join_email| join_email.language == member.language}
    SendgridMailer.user_email(join_email, member)
  end
  handle_asynchronously(:send_join_email) unless Rails.env.test?

end
