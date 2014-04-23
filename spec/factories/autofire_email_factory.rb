# == Schema Information
#
# Table name: autofire_emails
#
#  id             :integer          not null, primary key
#  subject        :string(255)
#  body           :text
#  enabled        :boolean
#  action_page_id :integer
#  language_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  from           :string(255)
#  reply_to       :string(255)
#  deleted_at     :datetime
#

FactoryGirl.define do
	factory :autofire_email do
		action_page { create(:action_page) }
		language    { create(:language) }
		enabled			true
    from        "somebody@somewhere.com"
    reply_to    "somebody@somewhere.com"
		subject 		"Email subject"
  	body 				"Email body"
	end
end
