# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_tag do
    sequence(:name) {|n| "My Tag #{n}" }
    movement
  end
end
