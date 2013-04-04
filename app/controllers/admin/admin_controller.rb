module Admin
  class AdminController < ApplicationController
    include CrudActions

    before_filter { I18n.locale = :en }
    before_filter :authenticate_platform_user!
    before_filter :authenticate_admin!
    before_filter :set_current_user
    before_filter :set_nocache_headers
    before_filter :load_movement

    class_attribute :nav_category
    self.nav_category = :movements

    rescue_from CanCan::AccessDenied do 
      if anyone_signed_in? 
        render :text => 'Access Denied', :status => :not_found
      else
        deny_access
      end
    end

    def active_nav?(nav_name)
      nav_name == self.nav_category
    end

    def authenticate_admin!
      return if current_platform_user.is_admin? || current_platform_user.has_user_affiliations?

      flash[:error] = 'Only administrators can view the admin pages'
      redirect_to root_path
    end

    def set_current_user
      PlatformUser.current_user = current_platform_user
    end

    def set_nocache_headers
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma'] = 'no-cache'
    end

    def load_movement
      if params[:movement_id]
        @movement = Movement.find(params[:movement_id])
        authorize! :read, @movement
      end
    end
  end
end
