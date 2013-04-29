class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?
    if user.is_admin?
      permissions_for_platform_admin
    else
      default_permissions_for_platform_users(user)
      permissions_for_movement_admin(user)
      permissions_for_campaigner(user)
      permissions_for_senior_campaigner(user)
    end
  end

  private

  def permissions_for_platform_admin
    can :manage, :all
    # not required just for readability
    can :toggle_platform_admin_role, PlatformUser
    can :refund, Transaction
  end

  def default_permissions_for_platform_users(user)
    permissions_scoped_within_movement(user, :manage, JoinEmail, UserAffiliation::ROLES)
    permissions_scoped_within_movement(user, :manage, EmailFooter, UserAffiliation::ROLES)
  end

  def permissions_for_movement_admin(user)
    can [:read, :update, :destroy], Movement do |movement|
      movement_exists_for_user_and_roles?(user, movement, UserAffiliation::ADMIN)
    end
    permissions_scoped_within_movement(user, :send, Blast, UserAffiliation::ADMIN)
    permissions_scoped_within_movement(user, :manage, Homepage, UserAffiliation::ADMIN)
    permissions_scoped_within_movement(user, :manage, Campaign, UserAffiliation::ADMIN)
    can [:read, :create, :update], PlatformUser if user.is_movement_admin?
  end

  def permissions_for_campaigner(user)
    permissions_for_campaigner_roles(user, UserAffiliation::CAMPAIGNER)
  end

  def permissions_for_senior_campaigner(user)
    permissions_for_campaigner_roles(user, UserAffiliation::SENIOR_CAMPAIGNER)
    permissions_scoped_within_movement(user, :send, Blast, UserAffiliation::SENIOR_CAMPAIGNER)
  end

  def permissions_for_campaigner_roles(user, role)
    can :read, Movement do |movement|
      movement_exists_for_user_and_roles?(user, movement, role)
    end
    #TODO need to scope this within movement too and need to write specs
    if user.is_campaigner? || user.is_senior_campaigner?
      can :export, [AskStatsTable, EmailStatsTable]
    end
  end

  def permissions_scoped_within_movement(user, action, subject, roles)
    can action, subject do |obj|
      movement_exists_for_user_and_roles?(user, obj.movement, roles)
    end
  end

  def movement_exists_for_user_and_roles?(user, movement, roles)
    UserAffiliation.for_user_movement_roles(user, movement, roles).exists?
  end

end
