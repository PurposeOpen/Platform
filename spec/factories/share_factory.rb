# == Schema Information
#
# Table name: shares
#
#  id         :integer          not null, primary key
#  share_type :string(255)
#  user_id    :integer
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :share do
  end

  factory :facebook_share, :parent => :share do
    share_type Share::FACEBOOK
  end

  factory :twitter_share, :parent => :share do
    share_type Share::TWITTER
  end

  factory :email_share, :parent => :share do
    share_type Share::EMAIL
  end
end
