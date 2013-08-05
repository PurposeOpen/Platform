require "spec_helper"

describe 'SendgridMailer' do
  let(:english) { FactoryGirl.create(:english) }
  let(:walkfree) { FactoryGirl.create(:movement, :name => "WalkFree", :url => "http://walkfree.org", :languages => [english]) }
  let(:donald) { FactoryGirl.create(:leo, :first_name => "Donald", :movement => walkfree) }
  let(:steve) { FactoryGirl.create(:brazilian_dude, :first_name => "Steve", :movement => walkfree) }

  let(:email_to_send) do
    email_to_send = FactoryGirl.create(:email_with_tokens, :subject => 'Meltdown!', :from => "Your Name <info@yourdomain.org>", :language => english)
    email_to_send.blast.push.campaign.movement = walkfree
    email_to_send.footer.html = "<p>html footer</p>"
    email_to_send.footer.text = "text footer"
    email_to_send.save!
    email_to_send
  end

  context 'individual email' do
    it 'should not be sent to permanently unsubscribed members' do
      user = create(:user, :email => 'bob@thoughtworks.com')
      user.permanently_unsubscribe!

      SendgridMailer.user_email(email_to_send, user)

      ActionMailer::Base.deliveries.size.should eql(0)
    end
  end

  describe "email blast" do

    before { AppConstants.stub(:enable_unfiltered_blasting) { false } }

    it "should send the email to sendgrid, with the corresponding API headers" do
      donald_hash = Base64.urlsafe_encode64("userid=#{donald.id},emailid=#{email_to_send.id}")
      steve_hash = Base64.urlsafe_encode64("userid=#{steve.id},emailid=#{email_to_send.id}")
      AppConstants.stub(:enable_unfiltered_blasting) { true }
      SendgridMailer.blast_email(email_to_send, :recipients => ['another@dude.com', 'leonardo@borges.com']).deliver

      ActionMailer::Base.deliveries.size.should eql(1)

      @delivered = ActionMailer::Base.deliveries.last
      @delivered.should have_body_text(/\{NAME\|Friend\}/)
      @delivered.should have_body_text(/\{POSTCODE\|Nowhere\}/)
      @delivered.should have_body_text(/t=\{TRACKING_HASH\|NOT_AVAILABLE\}/)

      @delivered.html_part.body.should include "<p>html footer</p>"
      @delivered.text_part.body.should include "text footer"

      @delivered.html_part.body.should include %{Pls click <a href="{MOVEMENT_URL|}/?t={TRACKING_HASH|NOT_AVAILABLE}">{MOVEMENT_URL|}</a>}
      @delivered.text_part.body.should match /Pls click {MOVEMENT_URL|}t={TRACKING_HASH|NOT_AVAILABLE}/

      @delivered.should have_subject(/Meltdown!/)
      @delivered.should deliver_to(AppConstants.no_reply_address)

      expected_header = {
        :to => ['another@dude.com', 'leonardo@borges.com'],
        :category => [
          "push_#{email_to_send.blast.push.id}",
          "blast_#{email_to_send.blast.id}",
          "email_#{email_to_send.id}",
          email_to_send.blast.push.campaign.movement.friendly_id,
          Rails.env,
          email_to_send.language.iso_code
        ],
        :sub => {
             "{NAME|Friend}" => ["Steve", "Donald"],
             "{POSTCODE|Nowhere}" => ["9999", "9999"],
             "{EMAIL|}" => [steve.email, donald.email],
             "{MOVEMENT_URL|}" => [ walkfree.url, walkfree.url ],
             "{TRACKING_HASH|NOT_AVAILABLE}" => [steve_hash, donald_hash]
        },
        :unique_args => { :email_id => email_to_send.id }
      }.to_json
      @delivered.should have_header("X-SMTPAPI", expected_header)
      @delivered.should have_header("from", "Your Name <info@yourdomain.org>")
      @delivered.should have_header("reply-to", "Your Name <reply_to@yourdomain.org>")
      @delivered.should have_header("content-type", /multipart/)
    end

    it "enable_unfiltered_blasting environment variable determines whether emails are filtered for whitelisted domains" do
      recipients = ['leonardo@gmail.com',
                    'another@generic.org',
                    'not-me@hotmail.com',
                    'david@yourdomain.org',
                    'porpoise@yourotherdomain.com',
                    'person@generic.org']
      recipients.each do |email|
        FactoryGirl.create(:user, :email => email)
      end

      SendgridMailer.blast_email(email_to_send, :recipients => recipients).deliver

      ActionMailer::Base.deliveries.size.should eql(1)

      @delivered = ActionMailer::Base.deliveries.last
      @delivered.header['X-SMTPAPI'].value.should match(/another@generic.org/)
      @delivered.header['X-SMTPAPI'].value.should match(/david@yourdomain.org/)
      @delivered.header['X-SMTPAPI'].value.should match(/porpoise@yourotherdomain.com/)
      @delivered.header['X-SMTPAPI'].value.should match(/person@generic.org/)
      @delivered.header['X-SMTPAPI'].value.should_not match(/not-me@hotmail.com/)
      @delivered.header['X-SMTPAPI'].value.should_not match(/leonardo@gmail.com/)

      AppConstants.stub(:enable_unfiltered_blasting) { true }
      SendgridMailer.blast_email(email_to_send, :recipients => ['leonardo@gmail.com',
                                                                'another@thoughtworks.com',
                                                                'not-me@hotmail.com',
                                                                'david@yourdomain.org']).deliver

      ActionMailer::Base.deliveries.size.should eql(2)

      @delivered = ActionMailer::Base.deliveries.last
      @delivered.header['X-SMTPAPI'].value.should match(/another@thoughtworks.com/)
      @delivered.header['X-SMTPAPI'].value.should match(/david@yourdomain.org/)
      @delivered.header['X-SMTPAPI'].value.should match(/not-me@hotmail.com/)
      @delivered.header['X-SMTPAPI'].value.should match(/leonardo@gmail.com/)
    end

    it "should prepend a test string to the email subject if in test mode" do
      donald_hash = Base64.urlsafe_encode64("userid=#{donald.id},emailid=#{email_to_send.id}")

      SendgridMailer.blast_email(email_to_send, :recipients => ['leonardo@borges.com'], :test => true).deliver

      ActionMailer::Base.deliveries.size.should eql(1)

      @delivered = ActionMailer::Base.deliveries.last
      @delivered.should have_subject(/\[TEST\]Meltdown!/)
    end

    it "should raise a RuntimeError if the size of the tokens array doesn't match the number of recipients" do
      expect {SendgridMailer.blast_email(email_to_send, :recipients => ['leonardo@borges.com','dave@mustaine.com', 'james@hetfield.com']).deliver}.to raise_error(RuntimeError)
    end
  end
end
