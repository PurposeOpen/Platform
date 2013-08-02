# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :postcode do
    country "MyString"
    zip "MyString"
    city "MyString"
    lat "MyString"
    lng "MyString"
  end
end
