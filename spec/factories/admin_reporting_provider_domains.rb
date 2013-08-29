# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin_reporting_provider_domain, :class => 'Admin::Reporting::ProviderDomain' do
    domain "MyString"
    provider "MyString"
  end
end
