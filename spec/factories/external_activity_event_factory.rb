# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_activity_event do
    association :movement
    association :user
    role "signer"
    partner "movement partner"
    sequence(:action_slug) {|n| "take_action_#{n}" }
    action_language_iso "en"
    activity "action_taken"
    source "controlshift"
  end
end
