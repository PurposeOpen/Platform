# == Schema Information
#
# Table name: external_activity_events
#
#  id                 :integer          not null, primary key
#  role               :string(255)
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  activity           :string(255)
#  external_action_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_activity_event do
    association :user
    association :external_action
    role "signer"
    activity "action_taken"
  end
end
