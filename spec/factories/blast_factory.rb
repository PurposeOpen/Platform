# == Schema Information
#
# Table name: blasts
#
#  id             :integer          not null, primary key
#  push_id        :integer
#  name           :string(255)
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  delayed_job_id :integer
#  failed_job_ids :string(255)
#

FactoryGirl.define do
  factory :blast do
    name                "Dummy Blast Name"
    push
    deleted_at          nil
  end
end
