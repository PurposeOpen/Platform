# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_footer do
    html "<p>MyText</p>"
    text "MyText"
    created_by "MyString"
    updated_by "MyString"
  end
end
