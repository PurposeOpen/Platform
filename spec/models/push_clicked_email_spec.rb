# == Schema Information
#
# Table name: push_clicked_emails
#
#  movement_id :integer          not null
#  user_id     :integer          not null
#  push_id     :integer          not null
#  email_id    :integer          not null
#  created_at  :datetime
#

require "spec_helper"

describe PushClickedEmail do

  it { should validate_presence_of(:movement_id) }
  it { should validate_presence_of(:push_id) }
  it { should validate_presence_of(:email_id) }
  it { should validate_presence_of(:user_id) }

end
