# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_action do
    movement_id 1
    source "MyString"
    partner "MyString"
    action_slug "MyString"
    sequence(:unique_action_slug) {|n| "MyString #{n}" }
    action_language_iso "MyString"
    external_tags { [FactoryGirl.create(:external_tag)] }
  end
end
