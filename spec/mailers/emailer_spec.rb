require "spec_helper"

describe Emailer do
  describe "target email" do
    it "correctly breaks up a list with comma delimiters" do
      email = Emailer.target_email(mock(:movement, :name => 'movement'), "bob@bobson.com,mrsanchez@gomez.com, juan@pablo.com", "", "", "")
      email.should bcc_to(["bob@bobson.com", "mrsanchez@gomez.com", "juan@pablo.com"])
    end

    it "correctly breaks up a list with space delimiters" do
      email = Emailer.target_email(mock(:movement, :name => 'movement'), "bob@bobson.com mrsanchez@gomez.com  juan@pablo.com", "", "", "")
      email.should bcc_to(["bob@bobson.com", "mrsanchez@gomez.com", "juan@pablo.com"])
    end

    it "correctly breaks up a list with semi-colon delimiters" do
      email = Emailer.target_email(mock(:movement, :name => 'movement'), "bob@bobson.com;mrsanchez@gomez.com; juan@pablo.com", "", "", "")
      email.should bcc_to(["bob@bobson.com", "mrsanchez@gomez.com", "juan@pablo.com"])
    end

    context do
      before do
        @movement = create(:movement, :name => 'Save the turtles')
        ENV["SAVETHETURTLES_TARGET_EMAIL_USERNAME"] = "david@walkfree.org"
        ENV["SAVETHETURTLES_TARGET_EMAIL_PASSWORD"] = "password"
        ENV["SAVETHETURTLES_TARGET_EMAIL_DOMAIN"] = "walkfree.org"
      end

      it "sets movement-specific target email configuration" do
        targets = 'bob@example.com, ted@example.com'
        from = 'does-not-matter@example.com'
        subject = 'subject'
        body = 'body'

        email_settings = Emailer.target_email(@movement, targets, from, subject, body).delivery_method.settings
        email_settings[:user_name].should == "david@walkfree.org"
        email_settings[:password].should == "password"
        email_settings[:domain].should == "walkfree.org"
      end

      it 'should handle line breaks in html mail' do
        body = "Hi,\r\n\r\nPlease take action against woodpeckers being killed.\r\nLets take some action.\nThanks."
        Emailer.target_email(@movement, 'someone@test.com', 'me@test.com', 'A subject', body).deliver
        ActionMailer::Base.deliveries.size.should eql(1)
        @delivered = ActionMailer::Base.deliveries.last

        html_part = @delivered.parts.select { |part| part.content_type =~ /text\/html/ }.first
        text_part = @delivered.parts.select { |part| part.content_type =~ /text\/plain/ }.first
        html_part.body.to_s.should include("Hi,<br/><br/>Please take action against woodpeckers being killed.<br/>Lets take some action")
      end
    end
  end
end
