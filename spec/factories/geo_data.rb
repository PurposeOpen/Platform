# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :geo_data do
    country_iso "us"
    postcode    "123456"
    city        "New York"
    lat         "12.23"
    lng         "-10.3"
  end
end
