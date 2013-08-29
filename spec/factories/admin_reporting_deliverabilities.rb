# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin_reporting_deliverability, :class => 'Admin::Reporting::Deliverability' do
    target_date "2013-04-05"
    report "MyText"
  end
end
