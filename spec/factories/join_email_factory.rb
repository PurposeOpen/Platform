# == Schema Information
#
# Table name: join_emails
#
#  id                 :integer          not null, primary key
#  subject            :string(255)
#  body               :text
#  movement_locale_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  from               :string(255)
#  created_by         :string(255)
#  updated_by         :string(255)
#  reply_to           :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :join_email do
    subject           "Welcome"
    from              "platform-test@example.com"
    body              "Thanks for joining us!"
  end
end
