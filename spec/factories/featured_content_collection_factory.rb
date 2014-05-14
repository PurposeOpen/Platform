# == Schema Information
#
# Table name: featured_content_collections
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  featurable_id   :integer
#  featurable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :featured_content_collection do
    name          "Carousel"
    association   :featurable, factory: :content_page
  end
end
