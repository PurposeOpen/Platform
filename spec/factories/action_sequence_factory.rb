# == Schema Information
#
# Table name: action_sequences
#
#  id                :integer          not null, primary key
#  campaign_id       :integer
#  name              :string(64)
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  created_by        :string(255)
#  updated_by        :string(255)
#  alternate_key     :integer
#  options           :text
#  published         :boolean
#  enabled_languages :text
#  slug              :string(255)
#

FactoryGirl.define do
  factory :action_sequence do
    campaign   { create(:campaign) }
    name       "Dummy Action Sequence Name"
    deleted_at nil
  end

  factory :published_action_sequence, :parent => :action_sequence do
    published true
    after(:build) do |as|
      as.enabled_languages = as.campaign.movement.languages.collect(&:iso_code)
    end
  end

  factory :static_action_sequence, :parent => :action_sequence do
    campaign nil
  end
end
