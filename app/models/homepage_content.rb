# == Schema Information
#
# Table name: homepage_contents
#
#  id            :integer          not null, primary key
#  banner_image  :string(255)
#  banner_text   :string(255)
#  updated_at    :datetime
#  updated_by    :string(255)
#  join_headline :string(255)
#  join_message  :string(255)
#  follow_links  :text
#  header_navbar :text
#  footer_navbar :text
#  homepage_id   :integer
#  language_id   :integer
#

class HomepageContent < ActiveRecord::Base
	acts_as_user_stampable

	belongs_to :homepage
	belongs_to :language
  
  serialize :follow_links, JSON

  delegate :iso_code, :to => :language
  delegate :name, :to => :language, :prefix => true

  validates_presence_of :language
  validate :follow_links_must_be_a_hash

  attr_protected :language_id

  after_initialize :defaults

  scope :by_iso_code,  lambda { |code| joins(:language).where(:languages => { :iso_code => code }) }

  LABELS = {:banner_image => 'Logo', :join_headline => 'Headline', :join_message => 'Join Text', :banner_text => 'Counter Text'}

  def content_complete?
    valid = true
    valid = false if (banner_image.blank? or banner_text.blank? or join_headline.blank? or join_message.blank? or follow_links.blank? or header_navbar.blank? or footer_navbar.blank?)
    valid
  end

  private

  def follow_links_must_be_a_hash
  	errors.add(:follow_links, "must be a hash") unless follow_links.is_a? Hash
  end

  def defaults
  	self.follow_links = HashWithIndifferentAccess.new(self.follow_links)
  end
end
