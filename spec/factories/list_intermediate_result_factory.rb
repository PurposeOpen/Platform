# == Schema Information
#
# Table name: list_intermediate_results
#
#  id         :integer          not null, primary key
#  data       :text
#  ready      :boolean          default(FALSE)
#  list_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  rules      :text
#

FactoryGirl.define do
  factory :list_intermediate_result do 
    ready false
  end
end
