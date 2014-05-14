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

class Share < ActiveRecord::Base
  FACEBOOK = 'facebook'
  TWITTER = 'twitter'
  EMAIL = 'email'
  SHARE_TYPES = [FACEBOOK, TWITTER, EMAIL]

  validates_inclusion_of :share_type, in: SHARE_TYPES
  validates_presence_of :page_id

  scope :shares_for, (proc do |page_id|
        where(page_id: page_id)
      end)


  def self.counts(page_id)
    counts = shares_for(page_id).group(:share_type).count
    SHARE_TYPES.each do |share_type|
      counts.merge!(share_type => 0) unless counts.include?(share_type)
    end
    counts
  end
end
