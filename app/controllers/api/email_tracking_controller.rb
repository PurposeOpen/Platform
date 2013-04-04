class Api::EmailTrackingController < Api::BaseController

  skip_before_filter :set_locale

  def email_opened
    if email_tracking_hash.valid?
      user =  email_tracking_hash.user
      email = email_tracking_hash.email
      UserActivityEvent.email_viewed!(user, email)
      head :ok
    else
      head 400
    end
  end

  def email_clicked
    if email_tracking_hash.valid?
      page = find_clicked_page
      user = email_tracking_hash.user
      email = email_tracking_hash.email
      page.register_click_from email, user
      head :ok
    else
      head 400
    end
  end

  private

  def find_clicked_page
    params[:page_type] == 'Homepage' ? movement.homepage : movement.find_page(params[:page_id])
  end

  def movement
    @movement ||= Movement.find(params[:movement_id])
  end
end
