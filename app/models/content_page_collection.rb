# == Schema Information
#
# Table name: content_page_collections
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  movement_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ContentPageCollection < ActiveRecord::Base
  has_many :content_pages
  belongs_to :movement
end
