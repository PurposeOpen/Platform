class ExternalTag < ActiveRecord::Base
  attr_accessible :movement_id, :name
  validates :movement_id, :name, presence: true
  belongs_to :movement
end
