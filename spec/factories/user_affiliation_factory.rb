# == Schema Information
#
# Table name: user_affiliations
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  movement_id :integer
#  role        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :user_affiliation do
    movement_id         1
    user_id             1
    role                UserAffiliation::ADMIN
  end
end
