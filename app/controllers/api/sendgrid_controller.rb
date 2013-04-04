class Api::SendgridController < Api::BaseController

  def event_handler
    member = User.find_by_movement_id_and_email(@movement.id, params[:email])
    head :ok and return if !member
    member.permanently_unsubscribe! if should_unsubscribe?

    if spam?
      email = Email.find(params[:email_id])
      UserActivityEvent.email_spammed!(member, email)
    end
    head :ok
  end

  def should_unsubscribe?
    hard_bounce? || spam?
  end

  def hard_bounce?
    params[:event] == 'bounce'
  end

  def spam?
    params[:event] == 'spamreport'
  end
end
