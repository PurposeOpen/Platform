module Jobs
  class SendJoinEmail
    @queue = :send_join_email
  
    def self.perform(user_id, movement_id)
      member = User.find(user_id)
      movement = Movement.find(movement_id)
      join_email = movement.join_emails.find {|join_email| join_email.language == member.language}
      SendgridMailer.user_email(join_email, member)
    end  
  end
end