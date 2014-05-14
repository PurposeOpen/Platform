# == Schema Information
#
# Table name: push_logs
#
#  id         :integer          not null, primary key
#  message    :text(2147483647)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PushLog < ActiveRecord::Base
  def self.log_exception(email, user_ids, exception)
    msg = "Push: #{email.blast.push.id} - Blast: #{email.blast.id} - Email: #{email.id} - User ids: #{[user_ids].flatten.join(",")} - Exception: #{exception.message}"
    PushLog.create!(message: msg)
  end
end
