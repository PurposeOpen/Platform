# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_activity_event do
    association :user
    association :external_action
    role "signer"
    activity "action_taken"
  end
end
