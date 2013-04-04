# == Schema Information
#
# Table name: email_footers
#
#  id                 :integer          not null, primary key
#  html               :text
#  movement_locale_id :integer
#  created_by         :string(255)
#  updated_by         :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  text               :text
#

class EmailFooter < ActiveRecord::Base
  include HasLinksWithEmailTrackingHash
  acts_as_user_stampable

  belongs_to :movement_locale
  has_one :movement, :through => :movement_locale
  has_one :language, :through => :movement_locale

  validates_uniqueness_of :movement_locale_id

  def html_with_beacon
    base_url = movement.url.starts_with?("http://", "https://") ? movement.url : "http://#{movement.url}"
    self.html + %{<img src="#{base_url}/beacon.gif?t={TRACKING_HASH|NOT_AVAILABLE}">}.html_safe
  end

  def html
    add_tracking_hash_to_html_links(read_attribute(:html))
  end

  def text
    add_tracking_hash_to_plain_text_links(read_attribute(:text))
  end
end
