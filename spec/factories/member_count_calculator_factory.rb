# == Schema Information
#
# Table name: member_count_calculators
#
#  id                :integer          not null, primary key
#  current           :integer
#  last_member_count :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  movement_id       :integer          not null
#

FactoryGirl.define do
  factory :member_count_calculator do
    current  10000
    movement { create(:movement) }
  end
end
