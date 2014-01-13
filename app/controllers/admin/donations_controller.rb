module Admin
  class DonationsController < AdminController
    layout 'movements'
    self.nav_category = :donations

    def search_results
      @user = User.find_by_email(params[:email])
      @donations = @user.try(:donations)
    end

    def deactivate
      donation = Donation.find(params[:id])
      user = donation.user
      if donation.deactivate
        redirect_to admin_movement_campaign_donations_path(params[:movement_id], params[:campaign_id], :email => user.email), :notice => "Donation deactivated."
      end
    end
  end
end
