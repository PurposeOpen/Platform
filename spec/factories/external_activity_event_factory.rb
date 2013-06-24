# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_activity_event do
    association :movement
    association :user
    role "signer"
    partner "movement partner"
    action_slug "take_action"
    action_language_iso "en"
    source "controlshift"
  end
end
