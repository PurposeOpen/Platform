module Jobs
  class SendgridEvent
    @queue = :event_tracking
  
    def self.perform(movement_id,params)
      Resque.logger.debug "Starting sendgrid event handler with params: #{params.inspect}"
      
      member = User.find_by_movement_id_and_email(movement_id, params['email'])
      raise "Sendgrid submitted an event for a non-member: #{params['email']}" if !member
      blast_email = Email.find(params['email_id'])
      raise "Sendgrid submitted an event for an invalid email_id: #{params['email_id']}" if !blast_email       
      
      case params['event'] 
        when 'bounce'
          UserActivityEvent.email_bounced!(member, blast_email, params['reason']) #record but take no action
        when 'spamreport'
          member.permanently_unsubscribe!(blast_email)
          UserActivityEvent.email_spammed!(member, blast_email)        
        when 'dropped' 
          case params['reason']
            when 'Invalid SMTPAPI header'
              #do nothing, probably a system error
            when 'Spam Content' #(if spam checker app enabled)
              #do nothing, we are not checking our content for spam rating
            when 'Unsubscribed Address'
              member.unsubscribe! #unsubscribe member but do not attribute to current blast_email, as it was from previos
            when 'Bounced Address'
              UserActivityEvent.email_bounced!(member, nil, "Dropped: #{params['reason']}") #record event but don't attribute (blast_email is nil)       
            when 'Spam Reporting Address'
              member.permanently_unsubscribe!(nil,params['reason']) #permanently unsubscribe member, but don't attribute to blast_email 
            when 'Invalid'
              member.permanently_unsubscribe!(nil,params['reason']) #permanently unsubscribe member, email address is invalid but don't attribute to blast_email            
          end
        when 'unsubscribe'
          member.unsubscribe!(blast_email)
      end
    
    

    end  
  end
end



# Processed
# event	email	category
# processed	Message recipient	The category you assigned
# Deferred
# event	email	response	attempt	category
# deferred	Message recipient	Full reponse from MTA	Delivery attempt #	The category you assigned
# Delivered
# event	email	response	category
# delivered	Message recipient	Full reponse from MTA	The category you assigned
# Open
# event	email	category
# open	Message recipient	The category you assigned
# Click
# event	email	url	category
# click	Message recipient	URL Clicked	The category you assigned
# Bounce
# event	email	status	reason	type	category
# bounce	Message recipient	3-digit status code	Bounce reason from MTA	Bounce/Blocked/Expired	The category you assigned
# Drop
# event	email	reason	category
# dropped	Message recipient	Drop reason	The category you assigned
# Spam Report
# event	email	category
# spamreport	Message recipient	The category you assigned
# Unsubscribe
# event	email	category
# unsubscribe	Message recipient	The category you assigned

# bounce/blocked/expired are temporary conditions, sometimes as a result of a Spam block (such as with Comcast) and sometimes when an ISP is down (like happens with AOL 2-3 times a year). The email should not be retired. These are each good data point to monitor, as if you see a spike you are getting blocked.
# On ‘bounce’ events, for your reporting break bounce/blocked/expired into three separate fields – as each should be reviewed individually. Bounces should be very consistent, it’s blocked and expired where you might see something pop.
# Certainly anyone with 'spamreport' should never be allowed back onto the list.
# There is a scenario I’m not sure how to get at. When a Gmail or Hotmail user unsubscribes in the ESP’s web UI, and that generates an unsubscribe using the list-unsubscribe header. In these cases Hotmail and Gmail know the user opted out, and I’d recommend never letting them back on. The only way for track these people down might be to query everyone who unsubscribed, but never clicked a link (this is assuming a click on the opt-out link is reported as a click). This also assumes you are using SendGrid for the list-unsubscribe feature and not handling that yourself.
# There is certainly an argument that anyone who unsubscribes should never be let back onto the list, but that is less a technical then business practice decision.
# Hope that help,
# Brian
