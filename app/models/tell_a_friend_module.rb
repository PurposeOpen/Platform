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

class TellAFriendModule < ContentModule
  TWITTER_MAXIMUM = 110

  option_fields :share_url,
                :headline, :message,
                :facebook_enabled, :facebook_title, :facebook_description, :facebook_image_url,
                :twitter_enabled, :tweet,
                :email_enabled, :email_subject, :email_body

  option_fields :include_action_counter, :action_counter_page_id

  TRIMMEABLE_FIELDS = [:share_url, :headline, :message, :facebook_title, :facebook_description, :tweet, :email_subject, :email_body]


  after_initialize :defaults
  before_validation :trim_strings

  warnings do
    validates_length_of :email_subject, :minimum => 2, :maximum => 256, :if => :email_enabled?
    validates_length_of :email_body, :minimum => 10, :if => :email_enabled?
    validates_length_of :tweet, :minimum => 2, :maximum => TWITTER_MAXIMUM, :if => :twitter_enabled?
    validates_presence_of :facebook_image_url, :if => :facebook_enabled?
    validates_length_of :share_url, :minimum => 3
    validates_presence_of :headline
    validates_presence_of :message
    validates_presence_of :action_counter_page_id, :if => :includes_action_counter?
  end

  placeable_in SIDEBAR

  def can_remove_from_page?
    false
  end

  def requires_user_details?
    false
  end

  [:email_enabled, :twitter_enabled, :facebook_enabled].each do |feature|
    define_method "#{feature}?" do
      send(feature) == '1'
    end
  end

  def includes_action_counter?
    include_action_counter == 'true'
  end

  private

  def defaults
    if self.options.blank?
      self.options = {
        :facebook_enabled => true,
        :twitter_enabled => true,
        :email_enabled => true,
        :include_action_counter => false
      }
    end
  end

  def trim_strings
    TRIMMEABLE_FIELDS.each do |trimmeable_field|
      if self.respond_to? trimmeable_field
        field = self.send(trimmeable_field)
        field.strip! unless !field || !field.respond_to?(:strip!)
      end
    end
  end
end
