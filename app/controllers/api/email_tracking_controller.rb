class Api::EmailTrackingController < Api::BaseController

  skip_before_filter :set_locale, :load_movement

  def email_opened  
    Resque.enqueue(Jobs::EmailOpenedEvent,params[:t])
    head :ok
  end

  def email_clicked
    Resque.enqueue(Jobs::EmailClickedEvent,params[:movement_id],params[:page_type],params[:page_id],params[:t])
    head :ok
  end
end
