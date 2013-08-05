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

  validates_inclusion_of :share_type, :in => SHARE_TYPES
  validates_presence_of :page_id

  scope :shares_for, (proc do |page_id|
        where(:page_id => page_id)
      end)

  after_create :async_increment_counter


  def self.counts(page_id)
    Rails.cache.fetch("shares_count_for_page_#{page_id}", expires_in: 24.hours) do
      counts = shares_for(page_id).group(:share_type).count
      SHARE_TYPES.each do |share_type|
        counts.merge!(share_type => 0) unless counts.include?(share_type)
      end
      counts
    end
  end

  def self.refresh_cache(page_id)
    #can't use a normal increment here because it's a hash, so instead we're just deleting the cache and refreshing the cache
    cache_key = "shares_count_for_page_#{page_id}"
    Rails.cache.delete(cache_key)
    Share.counts(page_id)
  end

  def async_increment_counter
    Resque.enqueue(Jobs::UpdateShareCache, self.page_id)
  end
end
