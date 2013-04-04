module Admin
  class JoinEmailsController < AdminController
    layout 'movements'
    self.nav_category = :settings

    def index
      @join_emails = @movement.join_emails.all
    end

    def update
      params[:join_emails].each do |id, attrs|
        join_email = JoinEmail.find(id)
        join_email.update_attributes(attrs)
      end
      flash[:notice] = 'Join emails updated.'
      redirect_to admin_movement_path(@movement)
    end

  end
end
