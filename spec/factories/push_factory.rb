# == Schema Information
#
# Table name: pushes
#
#  id          :integer          not null, primary key
#  campaign_id :integer
#  name        :string(255)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :push do |p|
    name                "Dummy Push Name"
    campaign            { create(:campaign) }
    deleted_at          nil
    updated_at          { generate(:time) }
    created_at          { generate(:time) }
  end
end
