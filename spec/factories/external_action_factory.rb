# == Schema Information
#
# Table name: external_actions
#
#  id                  :integer          not null, primary key
#  movement_id         :integer          not null
#  source              :string(255)      not null
#  partner             :string(255)
#  action_slug         :string(255)      not null
#  unique_action_slug  :string(255)      not null
#  action_language_iso :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_action do
    movement_id 1
    source "source"
    partner "partner"
    sequence(:action_slug) {|n| "take_action_#{n}" }
    action_language_iso "en"
    external_tags { [FactoryGirl.create(:external_tag)] }
  end
end
