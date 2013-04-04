# == Schema Information
#
# Table name: campaigns
#
#  id            :integer          not null, primary key
#  name          :string(64)
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  created_by    :string(255)
#  updated_by    :string(255)
#  alternate_key :integer
#  opt_out       :boolean          default(TRUE)
#  movement_id   :integer
#  slug          :string(255)
#

FactoryGirl.define do
  factory :campaign do |c|
    movement
    name                "Dummy Campaign Name"
    description         "Description of the campaign lorem ipsum dolor sit amet"
    opt_out             true
    deleted_at          nil
    updated_at          { generate(:time) }
    created_at          { generate(:time) }
  end
end
