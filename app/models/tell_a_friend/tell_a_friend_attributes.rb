# app/models/tell_a_friend/tell_a_friend_attributes.rb
module TellAFriend::TellAFriendAttributes

  extend ActiveSupport::Concern

  included do
    TWITTER_MAXIMUM = 110

	  option_fields :share_url,
	                :headline, :message,
	                :facebook_enabled, :facebook_title, :facebook_description, :facebook_image_url,
	                :twitter_enabled, :tweet,
	                :email_enabled, :email_subject, :email_body

	  option_fields :include_action_counter, :action_counter_page_id

	  TRIMMEABLE_FIELDS = [:share_url, :headline, :message, :facebook_title, :facebook_description, :tweet, :email_subject, :email_body]


	  after_initialize :taf_defaults
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
  end

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
  def taf_defaults
    self.set_default_options({
      :facebook_enabled => true,
      :twitter_enabled => true,
      :email_enabled =>  true,
      :include_action_counter => false,
    })
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