require "spec_helper"

describe EmailRecipientDetail do

  describe 'initialize' do

    it 'should calculate recipients_count' do
      email = FactoryGirl.create(:email, :test_sent_at => Time.now)
      email_recipient_detail = EmailRecipientDetail.create_with(email, [1,2,3])
      email_recipient_detail.recipients_count.should eq 3
    end

    it 'should store recipients as comma separated string' do
      email = FactoryGirl.create(:email, :test_sent_at => Time.now)
      email_recipient_detail = EmailRecipientDetail.create_with(email, [1,2,3])
      email_recipient_detail.sent_to_users_ids.should eq "1,2,3"
    end

  end
end