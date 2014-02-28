require 'json'

class Api::SendgridController < Api::BaseController

  http_basic_authenticate_with name: AppConstants.sendgrid_user, password: AppConstants.sendgrid_password

  def event_handler
    events = JSON.parse(request.body.read)
    events.each do |evt|
      handle_event(@movement.id, evt)
    end

    head :ok
  end

  def handle_event(movement_id, event)
    evt = SendgridEvents::create(movement_id, event)
    evt.delay.handle
  end

end
