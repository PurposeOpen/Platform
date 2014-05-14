# == Schema Information
#
# Table name: platform_users
#
#  id                     :integer          not null, primary key
#  email                  :string(256)      not null
#  first_name             :string(64)
#  last_name              :string(64)
#  mobile_number          :string(32)
#  home_number            :string(32)
#  encrypted_password     :string(255)
#  password_salt          :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  is_admin               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

class PlatformUser < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable
  acts_as_paranoid

  cattr_accessor :current_user

  has_many :user_affiliations, foreign_key: "user_id"
  has_many :movements, through: :user_affiliations
  accepts_nested_attributes_for :user_affiliations, allow_destroy: true

  validates_format_of :email, with: VALID_EMAIL_REGEX
  validates_uniqueness_of :email

  after_create :send_confirmation_email

  searchable do
    text  :id
    text  :first_name
    text  :last_name
    text  :email
    boolean :is_admin
    time :updated_at
    integer :movement_ids, multiple: true
  end
  handle_asynchronously :solr_index

  def full_name
    joined = "#{first_name} #{last_name}".strip
    joined.blank? ? 'Unknown Username' : joined.titlecase
  end
  alias_method :name, :full_name

  def movements_administered
    is_admin? ? Movement.all : movements.for_role(UserAffiliation::ADMIN)
  end

  def movements_allowed
    is_admin? ? Movement.all : movements.for_all_roles.all
  end

  def primary_movement
    movements_administered.first || movements_allowed.first
  end

  def secondary_movements
    movements_allowed - [ primary_movement ]
  end

  def is_movement_admin?
    user_affiliations.for_roles(UserAffiliation::ADMIN).exists?
  end

  def is_campaigner?
    user_affiliations.for_roles(UserAffiliation::CAMPAIGNER).exists?
  end

  def is_senior_campaigner?
    user_affiliations.for_roles(UserAffiliation::SENIOR_CAMPAIGNER).exists?
  end

  def user_affiliation_for_movement(movement)
    user_affiliations.for_movement(movement).first
  end

  def has_user_affiliations?
    user_affiliations.exists?
  end

  private
  def send_confirmation_email
    PlatformUserMailer.subscription_confirmation_email(self).deliver
  end
  handle_asynchronously :send_confirmation_email unless Rails.env.test?

end
