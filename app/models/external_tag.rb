class ExternalTag < ActiveRecord::Base
  attr_accessible :movement_id, :name

  has_and_belongs_to_many :external_actions, uniq: true

  validates :movement_id, :name, presence: true
  belongs_to :movement
end
