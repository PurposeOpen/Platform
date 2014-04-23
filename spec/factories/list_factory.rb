# == Schema Information
#
# Table name: lists
#
#  id                           :integer          not null, primary key
#  rules                        :text             default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  blast_id                     :integer
#  saved_intermediate_result_id :integer
#  deleted_at                   :datetime
#

FactoryGirl.define do
  factory :list do
    blast
  end
end
