# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_activity_event do
    association :user, :factory => :user
    partner "movement partner"
    source "controlshift"
    action "take action"
    action_language_iso_code "en"
    role "signer"
  end
end
