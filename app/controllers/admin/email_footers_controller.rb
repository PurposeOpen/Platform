module Admin
  class EmailFootersController < AdminController
    layout 'movements'
    self.nav_category = :settings

    def index
      @email_footers = @movement.email_footers.all
    end

    def update
      params[:email_footer].each do |id, attrs|
        email_footer = EmailFooter.find(id)
        email_footer.update_attributes(attrs)
      end
      flash[:notice] = 'Email footers updated.'
      redirect_to admin_movement_path(@movement)
    end

  end
end
