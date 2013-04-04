# == Schema Information
#
# Table name: user_affiliations
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  movement_id :integer
#  role        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserAffiliation < ActiveRecord::Base
  ADMIN = "admin"
  CAMPAIGNER = "campaigner"
  SENIOR_CAMPAIGNER = "campaigner_senior"
  ROLES = [ADMIN, CAMPAIGNER, SENIOR_CAMPAIGNER]
  enum_attr :role, ROLES do
    label ADMIN.to_sym => "Admin"
    label CAMPAIGNER.to_sym => "Campaigner"
    label SENIOR_CAMPAIGNER.to_sym => "Senior Campaigner"
    is_admin? { admin? }
    is_campaigner? { campaigner? }
    is_campaigner_senior? { campaigner_senior? }
  end
  validates_presence_of :user_id
  validates_presence_of :movement_id
  validates_uniqueness_of :user_id, :scope => :movement_id

  belongs_to :platform_user, :foreign_key => "user_id"
  belongs_to :movement

  scope :for_user_movement_roles, lambda {|user, movement, roles| where(user_id: user.id, movement_id: movement.id, role: roles) }
  scope :for_roles, lambda {|roles| where(role: roles) }
  scope :for_movement, lambda {|movement| where(movement_id: movement.id) }

  def self.roles_options_for_select
    enumerated_attributes[:role].select_options
  end

end
