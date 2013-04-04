# == Schema Information
#
# Table name: content_page_collections
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  movement_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :content_page_collection do
    movement
    name          "Jobs"
    content_pages []
  end
end
