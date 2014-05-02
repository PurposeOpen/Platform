class Api::SendgridController < Api::BaseController

  def event_handler
    begin
      movement_id = params['movement_id']
      events = params['_json']

      events.each do |event|
        Delayed::Job.enqueue SendgridEventJob.new(movement_id, event)
      end
    rescue => e
      NewRelic::Agent.notice_error(e)
    end

    head :ok
  end

end
