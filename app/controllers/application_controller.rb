class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  before_filter :set_return_to_path

  rescue_from CanCan::AccessDenied, :with => :access_denied

  ## CanCan assumes there is a method called current_user
  ## For the purpose of the members/platform users split, we need to use a different method, current_platform_user
  ## That's why we need to override current_ability
  def current_ability
    @current_ability ||= Ability.new(current_platform_user)
  end

  def set_return_to_path
    session[:return_to] = params[:return_to] if params[:return_to]
  end

  def email_tracking_hash
    @email_tracking_hash ||= EmailTrackingHash.decode(params[:t])
  end

  def after_sign_in_path_for(resource_or_scope)
    case resource_or_scope
    when :platform_user, PlatformUser
      store_location = session[:return_to]
      clear_stored_location
      (store_location.nil?) ? '/' : store_location.to_s
      if resource_or_scope.respond_to?(:primary_movement)
        admin_movement_path(resource_or_scope.primary_movement)
      else
        root_path
      end
    else
      super
    end
  end

  def access_denied
    if anyone_signed_in?
      warden.custom_failure!
      render :file => 'public/401', :status => 401
    else
      deny_access
    end
  end

  def handle_unverified_request
    Rails.env.production? ? reset_session : raise(ActionController::InvalidAuthenticityToken.new)
  end
end
