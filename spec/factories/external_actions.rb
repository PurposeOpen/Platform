# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_action do
    movement_id 1
    source "MyString"
    partner "MyString"
    action_slug "MyString"
    unique_action_slug "MyString"
    action_language_iso "MyString"
  end
end
