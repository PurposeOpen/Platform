class SendgridEventJob
  attr_reader :movement_id, :event

  def initialize(movement_id, event)
    @movement_id = movement_id
    @event = event
  end

  def perform
    return unless user = User.find_by_movement_id_and_email(movement_id, event['email'])

    case event['event']
    when 'bounce'
      user.permanently_unsubscribe!
    when 'unsubscribe'
      user.unsubscribe!(email)
    when 'spamreport'
      user.permanently_unsubscribe!(email)
      UserActivityEvent.email_spammed!(user, email)
    when 'dropped'
      case event['reason']
      when 'Unsubscribed Address'
        user.unsubscribe!
      when 'Bounced Address'
        user.permanently_unsubscribe!
      when 'Spam Reporting Address'
        user.permanently_unsubscribe!
      when 'Invalid'
        user.permanently_unsubscribe!
      end
    end
  end

  private

  def email
    @email ||= Email.find(event['email_id'])
  end

end