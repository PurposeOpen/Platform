# == Schema Information
#
# Table name: movements
#
#  id                        :integer          not null, primary key
#  name                      :string(20)       not null
#  url                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  subscription_feed_enabled :boolean
#  created_by                :string(255)
#  updated_by                :string(255)
#  password_digest           :string(255)
#  slug                      :string(255)
#  crowdring_url             :string(255)
#

FactoryGirl.define do
  sequence :movement_name do |i|
    "Dummy Movement #{i}"
  end

  factory :movement do
    name                  { generate(:movement_name) }
    url                   "http://www.yourdomain.com"
    languages             { [Language.find_by_name("English") || FactoryGirl.create(:english)] }

    after(:create) do |m|
      m.default_iso_code = m.languages.first.iso_code unless m.languages.empty?
      m.movement_locales.each do |ml|
        ml.join_email = FactoryGirl.create(:join_email)
      end
    end
  end
end
