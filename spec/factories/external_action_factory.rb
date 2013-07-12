# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_action do
    movement_id 1
    source "source"
    partner "partner"
    sequence(:action_slug) {|n| "take_action_#{n}" }
    action_language_iso "en"
    external_tags { [FactoryGirl.create(:external_tag)] }
  end
end
