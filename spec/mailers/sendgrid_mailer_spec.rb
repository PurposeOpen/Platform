require "spec_helper"

describe SendgridMailer do
  it 'should process the email body, making token substitutions as necessary' do
    email = FactoryGirl.build(:email, :body => """Dear {NAME},
      click {PASSWORD_URL} to unsubscribe from {MOVEMENT_NAME}.
      This email was sent to {FULLNAME} ({NAME}), {EMAIL}, {POSTCODE}, {COUNTRY}.""")

    movement = FactoryGirl.create(:movement, :name => "Pinkpop")
    user = FactoryGirl.build(:user, :first_name => "Guybrush", :last_name => "Bop", :email => "guybrush@example.com",
      :postcode => "10000", :country_iso => "us", :language => FactoryGirl.create(:english), :movement => movement)

    mailer = SendgridMailer.send(:new)
    mailer.pre_process_body(email.body, user)[:html].should == """Dear Guybrush,
      click #{new_user_password_url} to unsubscribe from Pinkpop.
      This email was sent to Guybrush Bop (Guybrush), guybrush@example.com, 10000, United States."""
  end

  it 'should use URL from links on plain text' do
    email = FactoryGirl.build(:email, :body => """Dear {NAME},
      This is the link: <a href='http://example.com/my_link'>a link</a>""")
    movement = FactoryGirl.create(:movement, :name => "Pinkpop")
    user = FactoryGirl.build(:user, :first_name => "Guybrush", :last_name => "Bop", :email => "guybrush@example.com",
      :postcode => "10000", :country_iso => "us", :language => FactoryGirl.create(:english), :movement => movement)

    mailer = SendgridMailer.send(:new)
    
    mailer.pre_process_body(email.body, user)[:text].should == """Dear Guybrush,
      This is the link: http://example.com/my_link"""
  end

  it 'should raise a descriptive error the email body, making token substitutions as necessary, if body is nil' do
    email = FactoryGirl.build(:email, :body => nil)
    user = FactoryGirl.build(:user, :first_name => "Guybrush")

    mailer = SendgridMailer.send(:new)
    lambda do
      mailer.pre_process_body(email.body, user)
    end.should raise_error(RuntimeError, /Error sending email: body cannot be empty/)
  end

  it 'should accept additional tokens on user emails' do
    action_page = FactoryGirl.create(:action_page)
    movement = action_page.movement
    movement.movement_locales.first.email_footer = FactoryGirl.create(:email_footer)

    email = FactoryGirl.create(:autofire_email, :body => 'Hey, say welcome to {SEASON|}!', :action_page => action_page, :language => movement.movement_locales.first.language)
    user = FactoryGirl.create(:user, :first_name => 'Elrond')

    mailer = SendgridMailer.send(:new)
    email = mailer.user_email(email, user, :SEASON => "Summer")

    email.should have_body_text('Hey, say welcome to Summer!')
  end

  describe 'blast and autofire-specific mail configuration' do

    before do
      english = create(:english)
      movement = create(:movement, :name => 'Peanut Butter', :languages => [english])
      campaign = create(:campaign, :movement => movement)
      push = create(:push, :campaign => campaign)
      blast = create(:blast, :push => push)
      @email = create(:email, :blast => blast, :language => english)

      email_footer = create(:email_footer)
      email_footer.update_attribute('movement_locale_id', movement.movement_locales.first.id)
    end

    it 'should set list-unsubscribe header' do
      mailer = SendgridMailer.send(:new)
      options = {:recipients => ['bob@generic.org']}
      returnEmail = mailer.blast_email(@email, options)
      returnEmail.header['List-Unsubscribe'].value.should == "<mailto:Your Name <from@yourdomain.org>>"
    end


    it 'sets movement-specific configuration for autofire emails' do
      user = create(:user)
      ENV["PEANUTBUTTER_BLAST_EMAIL_USERNAME"] = "david@yourdomain.org"
      ENV["PEANUTBUTTER_BLAST_EMAIL_PASSWORD"] = "password"
      ENV["PEANUTBUTTER_BLAST_EMAIL_DOMAIN"] = "yourdomain.org"

      email_settings = SendgridMailer.user_email(@email, user).delivery_method.settings

      email_settings[:user_name].should == "david@yourdomain.org"
      email_settings[:password].should == "password"
      email_settings[:domain].should == "yourdomain.org"
    end

    it 'sets movement-specific configuration for blast emails' do
      ENV["PEANUTBUTTER_BLAST_EMAIL_USERNAME"] = "david@yourdomain.org"
      ENV["PEANUTBUTTER_BLAST_EMAIL_PASSWORD"] = "password"
      ENV["PEANUTBUTTER_BLAST_EMAIL_DOMAIN"] = "yourdomain.org"

      options = {:recipients => ['bob@generic.org']}
      email_settings = SendgridMailer.blast_email(@email, options).delivery_method.settings

      email_settings[:user_name].should == "david@yourdomain.org"
      email_settings[:password].should == "password"
      email_settings[:domain].should == "yourdomain.org"
    end
  end
end
