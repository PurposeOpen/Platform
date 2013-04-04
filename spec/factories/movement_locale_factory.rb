# == Schema Information
#
# Table name: movement_locales
#
#  id          :integer          not null, primary key
#  movement_id :integer
#  language_id :integer
#  default     :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :movement_locale do
    movement
    language
    join_email
    default true
  end
end
