# == Schema Information
#
# Table name: homepages
#
#  id          :integer          not null, primary key
#  movement_id :integer
#  draft       :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :homepage do
    movement
  end
end
