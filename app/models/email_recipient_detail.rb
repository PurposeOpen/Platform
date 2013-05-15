# == Schema Information
#
# Table name: email_recipient_details
#
#  id                :integer          not null, primary key
#  email_id          :integer
#  recipients_count  :integer
#  sent_to_users_ids :text

class EmailRecipientDetail < ActiveRecord::Base

  def self.create_with(email, recipients_id)
    email_recipient_detail = self.new
    email_recipient_detail.email_id = email.id
    email_recipient_detail.recipients_count = recipients_id.size
    email_recipient_detail.sent_to_users_ids = recipients_id
    email_recipient_detail
  end

end