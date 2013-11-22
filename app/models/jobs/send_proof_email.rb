module Jobs
  class SendProofEmail
    @queue = :send_proof_email

    def self.perform(email_id, default_test_email_recipient, recipients)
      recipients << default_test_email_recipient
      email = Email.find(email_id)
    	email.touch(:test_sent_at)
    	SendgridMailer.blast_email(email, {:recipients => recipients, :test => true}).deliver
    end
  end
end