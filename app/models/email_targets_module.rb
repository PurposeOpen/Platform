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

# "Email Targets Ask" module -- requests that user write and send their email or use the default one
class EmailTargetsModule < ContentModule
  option_fields :default_body, :default_subject, :targets,
                :button_text, :allow_editing, :emails_goal, :thermometer_threshold,
                :active, :disabled_title, :disabled_content

  def emails_goal=(value)
    write_option_field_value :emails_goal, value.to_i
  end

  def thermometer_threshold=(value)
    write_option_field_value :thermometer_threshold, value.to_i
  end

  after_initialize :defaults

  warnings do
    validates_length_of   :title, :maximum => 128, :minimum => 3, :if => :needs_title?
    validates_length_of   :public_activity_stream_template, :maximum => 1024, :minimum => 3, :if => :shows_activity_stream?
    validates_length_of   :button_text, :minimum => 1, :maximum => 64
    validates_length_of   :default_subject, :minimum => 2, :maximum => 256
    validates_presence_of :default_body
    validates_presence_of :emails_goal
    validates_presence_of :thermometer_threshold
    validates_numericality_of :emails_goal, :greater_than_or_equal_to => 0, :if => :emails_goal
    validates_numericality_of :thermometer_threshold, :greater_than_or_equal_to => 0, :less_than_or_equal_to => :emails_goal, :if => :emails_goal
    validate :targets_must_be_valid
    validates_presence_of :disabled_title, :unless => :active?
    validates_presence_of :disabled_content, :unless => :active?
  end

  placeable_in SIDEBAR

  TARGET_REGEX = /(\"|\')[^(\"|\')]*(\"|\')\s*<[^>]*>/
  TARGETS_REGEX = /^#{TARGET_REGEX}(,\s*#{TARGET_REGEX})*$/

  def self.for_container?(layout_container)
    layout_container == :sidebar
  end

  def can_remove_from_page?
    false
  end

  def as_json(opts={})
    super(opts).tap do |json|
      options_as_json = self.options.as_json(opts)
      options_as_json['targets_names'] = self.targets_names
      options_as_json.delete('targets')
      json['options'] = options_as_json
      json['emails_sent'] = emails_sent
    end
  end

  def take_action(user, action_info, page)
    raise DuplicateActionTakenError if UserEmail.where(:page_id => page, :user_id => user).count > 0

    user_email = UserEmail.new(:content_module => self,
      :subject => default_subject,
      :body => default_body,
      :targets => self.targets_emails.join(", "),
      :cc_me => action_info[:cc_me],
      :user => user,
      :action_page => page,
      :email => action_info[:email])

    user_email.subject = action_info[:subject] || default_subject if allow_editing
    user_email.body = action_info[:body] || default_body if allow_editing
    user_email.body += body_signature(user,page)

    return false unless user_email.save
    user_email.send!
    user_email
  end

  def targets_names
    self.targets.try(:scan, /(?:\'|\")([^(?:\'|\")]*)(?:\'|\")/).flatten
  end

  def targets_emails
    self.targets.try(:scan, /(?:\'|\")[^(?:\'|\")]*(?:\'|\")\s*<([^>]*)>/).flatten
  end

  def emails_sent
    pages.first ? (UserEmail.where(:page_id => pages.first.id).count * targets_emails.size) : 0
  end

  def targets_must_be_valid
    if self.targets.nil? or !self.targets.match(TARGETS_REGEX)
      self.errors.add(:targets, "must be of the format: 'Name, Title' <name@example.com>, 'Joe, GI' <joe@example.com>")
    end

    unless self.targets.nil?
      self.targets.scan(/<([^>]*)>/).flatten.each do |address|
        address.strip!
        unless (address =~ VALID_EMAIL_REGEX)
          self.errors.add(:targets, "#{address} is not a valid email address.")
        end
      end
    end
  end

  def active?
    active == 'true'
  end

  private

  def body_signature(user,page)
    return "" if user.nil?
    signature = ""
    signature += "#{user.first_name} " if user.first_name
    signature += "#{user.last_name}" if user.last_name
    signature += "\n#{user.email}" if user.email
    signature += "\n#{user.street_address}" if user.street_address && page.required_user_details[:street_address] == :required
    signature += "," if user.street_address && user.suburb && page.required_user_details[:street_address] == :required
    signature += "#{user.suburb}" if user.suburb && user.street_address && page.required_user_details[:suburb] == :required
    signature += "\n#{user.postcode}" if user.postcode && page.required_user_details[:postcode_number] == :required
    signature = "\n\n\n" + signature unless signature == ""
    return signature
  end

  def defaults
    self.button_text = "Send!" unless self.button_text
    self.allow_editing = true if self.allow_editing.nil?
    self.public_activity_stream_template = "{NAME|A member}, {COUNTRY|}<br/>[{HEADER}]:if expand("%") == ""|browse confirm w|else|confirm w|endif
    " unless self.public_activity_stream_template
    self.active = 'true' unless self.active
  end

end
