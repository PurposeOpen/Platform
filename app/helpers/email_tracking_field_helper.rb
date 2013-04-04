module EmailTrackingFieldHelper

  def email_tracking_field
    raw(%Q{<input type="hidden" name="t" value ="#{params[:t]}">}) unless params[:t].blank?
  end
end