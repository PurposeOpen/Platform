# == Schema Information
#
# Table name: external_tags
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  movement_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ExternalTag < ActiveRecord::Base
  attr_accessible :movement_id, :name

  has_and_belongs_to_many :external_actions, uniq: true
  belongs_to :movement

  validates_presence_of :movement_id, :name
  validates_uniqueness_of :name, scope: [:movement_id]
end
