module Admin
  class UsersController < AdminController
    layout 'movements'
    self.nav_category = :users

    PAGE_SIZE = 20
    skip_authorize_resource
    load_and_authorize_resource :platform_user, :instance_name => :user, :parent => false
    before_filter :cannot_update_yourself, :only => [:create, :update]

    def index
      # authorize! :manage, PlatformUser
      search = PlatformUser.search {
        keywords params[:query]
        with :is_admin, 1 unless params[:admins_only].nil?
        paginate :per_page => PAGE_SIZE, :page => params[:page]
        order_by :updated_at, :asc
      }
      @users = search.results
    end

    def create
      cleanup_empty_roles(false)
      ua = extract_user_affiliations

      @user = PlatformUser.new(params[:user])

      if @user.save && @user.update_attributes(:user_affiliations_attributes => ua)
        redirect_to admin_movement_users_path(@movement), :notice => 'PlatformUser has been created.'
      else
        flash[:error] = 'Your changes have NOT BEEN SAVED YET. Please fix the errors below.'
        render :action => 'new'
      end
    end

    def extract_user_affiliations
      ua = params[:user].blank? ? {} : params[:user].delete(:user_affiliations_attributes)
      ua.nil? ? {} : ua
    end

    def update
      cleanup_empty_roles
      @user.attributes = params[:user]
      authorize! :toggle_platform_admin_role, @user if @user.is_admin_changed?

      if @user.save
        redirect_to admin_movement_users_path(@movement), :notice => "'#{@user.name}' has been updated."
      else
        flash[:error] = 'Your changes have NOT BEEN SAVED YET. Please fix the errors below.'
        render :action => 'edit'
      end
    end

    def cleanup_empty_roles(destroy=true)
      return if params[:user].blank? || params[:user][:user_affiliations_attributes].blank?
      user_affiliations = params[:user][:user_affiliations_attributes]
      user_affiliations.each do |item|
        if item[1]['role'].blank?
          if destroy
            item[1]['_destroy'] = true
          else
            user_affiliations.delete(item[0])
          end

        end
      end
    end
    private :cleanup_empty_roles

    def destroy
      @user = PlatformUser.find(params[:id])
      @user.destroy
      redirect_to admin_movement_users_path(@movement), :notice => "'#{@user.name}' has been deleted."
    end

    def cannot_update_yourself
      # We tried specifying this in CanCan directly and it proved to be tricky.
      raise CanCan::AccessDenied.new('Cannot update yourself') if @user.id == current_platform_user.id
    end
    private :cannot_update_yourself


  end
end
