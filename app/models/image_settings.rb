# == Schema Information
#
# Table name: image_settings
#
#  carousel_image_height        :integer
#  carousel_image_width         :integer
#  carousel_image_dpi           :integer
#  action_page_image_height     :integer
#  action_page_image_width      :integer
#  action_page_image_dpi        :integer
#  featured_action_image_height :integer
#  featured_action_image_width  :integer
#  featured_action_image_dpi    :integer
#  facebook_image_height        :integer
#  facebook_image_width         :integer
#  facebook_image_dpi           :integer
#  movement_id                  :integer          primary key
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class ImageSettings < ActiveRecord::Base
  self.primary_key = :movement_id
  belongs_to :movement
end
