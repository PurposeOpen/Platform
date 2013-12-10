# encoding: utf-8
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

require 'money'

class TafDonationModule < DonationModule
	TellAFriend::TellAFriendAttributes
	#TAF Options, will need to figure out someone to make the module include this for us....

	option_fields :share_url,
	                :headline, :message,
	                :facebook_enabled, :facebook_title, :facebook_description, :facebook_image_url,
	                :twitter_enabled, :tweet,
	                :email_enabled, :email_subject, :email_body

  option_fields :include_action_counter, :action_counter_page_id, :show_taf

	after_initialize :taf_defaults

	def taf_defaults
    self.options ||= {}
    self.options[:facebook_enabled] = true
    self.options[:twitter_enabled]= true
    self.options[:email_enabled] =  true
    self.options[:include_action_counter] = false
  end

  def classification
    TaxDeductibleTafDonationModule::DONATION_CLASSIFICATION
  end
end
