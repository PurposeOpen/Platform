module Admin
  class DonationsController < AdminController
    layout 'movements'
    self.nav_category = :donations

    PAGE_SIZE = 20

    def index
      @user = User.find_by_email(params[:email])
      @donations = @user.try(:donations)
    end

    def edit
      @donation = Donation.find(params[:id])
      @user = @donation.user
    end

    def update
      @donation = Donation.find(params[:id])
      user = @donation.user
      if @donation.update_attributes(params[:donation])
        redirect_to admin_movement_donations_path(@movement, :email => user.email), :notice => "Donation email preferences updated."
      else
        flash[:error] = "Unable to update the donation email preferences."
        render :edit
      end
    end

    def deactivate
      donation = Donation.find(params[:id])
      user = donation.user
      if donation.deactivate
        redirect_to admin_movement_donations_path(@movement, :email => user.email), :notice => "Donation deactivated."
      end
    end
  end
end
