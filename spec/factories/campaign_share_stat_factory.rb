# == Schema Information
#
# Table name: campaign_share_stats
#
#  campaign_id          :integer          not null
#  facebook_shares      :integer
#  twitter_shares       :integer
#  email_shares         :integer
#  actions_before_share :integer
#  taf_page_id          :integer          primary key
#

FactoryGirl.define do
  factory :campaign_share_stat do |c|
    campaign
    facebook_shares 1234
    twitter_shares 700
    email_shares 567
  end
end

