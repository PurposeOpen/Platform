# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

require "spec_helper"

describe EmailTargetsModule do

  before do
    @page = FactoryGirl.create(:action_page)
  end

  def validated_email_targets_module(attrs)
    default_attrs = {active: 'true'}
    etm = FactoryGirl.build(:email_targets_module, default_attrs.merge(attrs))
    etm.valid?
    etm
  end

  it "should not be removed from the page" do
    EmailTargetsModule.new.can_remove_from_page?.should be_false
  end

  describe "validation" do
    it "attribute setter should set emails goal to 0 if blank or nil, and it should be valid without warnings" do
      pm = validated_email_targets_module(:emails_goal => nil, :thermometer_threshold => 0)
      pm.emails_goal.should == 0
      pm.should be_valid_with_warnings
    end

    it "should require a target greater than or equal to 0" do
      validated_email_targets_module(:emails_goal => -1, :thermometer_threshold => 0).should_not be_valid_with_warnings
      validated_email_targets_module(:emails_goal => 0, :thermometer_threshold => 0).should be_valid_with_warnings
      validated_email_targets_module(:emails_goal => 1, :thermometer_threshold => 0).should be_valid_with_warnings
    end

    it "should require a thermometer threshold between 0 and the goal value inclusive" do
      validated_email_targets_module(:emails_goal => 100, :thermometer_threshold => 0).should be_valid_with_warnings
      validated_email_targets_module(:emails_goal => 100, :thermometer_threshold => 50).should be_valid_with_warnings
      validated_email_targets_module(:emails_goal => 100, :thermometer_threshold => 100).should be_valid_with_warnings
      validated_email_targets_module(:emails_goal => 100, :thermometer_threshold => 110).should_not be_valid_with_warnings
    end

    it "should require a title between 3 and 128 characters" do
      validated_email_targets_module(:title => "Save the kittens!").should be_valid_with_warnings
      validated_email_targets_module(:title => "X" * 128).should be_valid_with_warnings
      validated_email_targets_module(:title => "X" * 129).should_not be_valid_with_warnings
      validated_email_targets_module(:title => "AB").should_not be_valid_with_warnings
    end

    it "should require a button text between 1 and 64 characters" do
      validated_email_targets_module(:button_text => "Save the kittens!").should be_valid_with_warnings
      validated_email_targets_module(:button_text => "X" * 64).should be_valid_with_warnings
      validated_email_targets_module(:button_text => "X" * 65).should_not be_valid_with_warnings
      validated_email_targets_module(:button_text => "").should_not be_valid_with_warnings
    end

    it "should create a default button text" do
      #NB we can't use the factory for this cherry
      page = FactoryGirl.create(:action_page)
      etm = EmailTargetsModule.create
      etm.button_text.should eql('Send!')
    end

    it "should require a default subject between 2 and 256 characters" do
      validated_email_targets_module(:default_subject => "Save the kittens!").should be_valid_with_warnings
      validated_email_targets_module(:default_subject => "X" * 256).should be_valid_with_warnings
      validated_email_targets_module(:default_subject => "X" * 257).should_not be_valid_with_warnings
      validated_email_targets_module(:default_subject => "").should_not be_valid_with_warnings
    end

    it "should be active by default" do
      email_targets_module = EmailTargetsModule.new
      email_targets_module.active.should be_true
    end

    it "should require only valid email addresses, with a minimum of 1" do
      validated_email_targets_module(:targets => "'user1' <user1@yourdomain.org>").should be_valid_with_warnings
      validated_email_targets_module(:targets => "'user1' <user1@yourdomain.org>, 'user2' <user2@yourdomain>").should_not be_valid_with_warnings
      validated_email_targets_module(:targets => "'user1' <user1@yourdomain.org>" * 257).should_not be_valid_with_warnings
      validated_email_targets_module(:targets => "").should_not be_valid_with_warnings
    end

    it "should allow email addresses with target names" do
      validated_email_targets_module(:targets => "'Johan' <johan@yourdomain.com>, 'Banana' <hammock@yourdomain.org>").should be_valid_with_warnings
    end

    it "should allow targets names, positions and emails" do
      validated_email_targets_module(
          :targets => "'Johan, JavaScript GeniOus' <johan@yourdomain.com>, 'Banana, Lazy Fruit' <hammock@yourdomain.org>").
          should be_valid_with_warnings
    end

    it "should validate the presence of targets" do
      validated_email_targets_module(:targets => nil).should_not be_valid_with_warnings
    end

    it "should required disabled title/content if disabled" do
      validated_email_targets_module(active: 'true', disabled_title: '', disabled_content:
        '').should be_valid_with_warnings
      validated_email_targets_module(active: 'false', disabled_title: '', disabled_content:
        'bar').should_not be_valid_with_warnings
      validated_email_targets_module(active: 'false', disabled_title: 'foo', disabled_content:
        '').should_not be_valid_with_warnings
      validated_email_targets_module(active: 'false', disabled_title: 'foo', disabled_content:
        'bar').should be_valid_with_warnings
    end
  end

  describe "taking an action" do
    it "should raise an error if the page/user combo has been seen before" do
      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:email_targets_module, :pages => [@page])
      ask.take_action(user, {}, @page)
      lambda { ask.take_action(user, {}, @page) }.should raise_error(DuplicateActionTakenError)
    end

    it "should send emails to the address of the module's targets" do
      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:email_targets_module,
        :targets => "\"Bond, James Bond\" <jbond@mi6.co.uk>, 'Clark Kent, journalist' <ckent@dailyplanet.com>")

      ask.take_action(user, {}, @page)

      user_email = UserEmail.where(:user_id => user.id, :content_module_id => ask.id).all.first
      user_email.targets.should eql "jbond@mi6.co.uk, ckent@dailyplanet.com"

      ActionMailer::Base.deliveries.size.should == 1
      ActionMailer::Base.deliveries.first.should bcc_to(["ckent@dailyplanet.com", "jbond@mi6.co.uk"])
    end

    it "should use subject and body provided by the user when allow editing flag is enabled" do
      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:email_targets_module,
        :default_subject => "Default Subject",
        :default_body => "Default Body",
        :allow_editing => true)

      user_provided_subject = "User Provided Subject"
      user_provided_body = "User Provided Body"

      ask.take_action(user, {
        :subject => user_provided_subject,
        :body => user_provided_body
      }, @page)

      user_email = UserEmail.where(:user_id => user.id, :content_module_id => ask.id).all.first
      user_email.subject.should eql user_provided_subject
      user_email.body.should match /#{user_provided_body}/

      ActionMailer::Base.deliveries.size.should == 1
      ActionMailer::Base.deliveries.first.should have_subject(user_provided_subject)
      ActionMailer::Base.deliveries.first.parts.last.body.to_s.should match /#{user_provided_body}/
    end

    it "should use email's default subject and body when nothing is provided" do
      default_subject = "Default Subject"
      default_body = "Default Body"

      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:email_targets_module,
        :default_subject => default_subject,
        :default_body => default_body,
        :allow_editing => true)

      ask.take_action(user, {}, @page)

      user_email = UserEmail.where(:user_id => user.id, :content_module_id => ask.id).all.first
      user_email.subject.should eql default_subject
      user_email.body.should match /#{default_body}/

      ActionMailer::Base.deliveries.size.should == 1
      ActionMailer::Base.deliveries.first.should have_subject(default_subject)
      ActionMailer::Base.deliveries.first.parts.last.body.to_s.should match /#{default_body}/
    end

    it "should always use email's default subject and body when the allow editing flag is disabled" do
      default_subject = "Default Subject"
      default_body = "Default Body"

      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:email_targets_module,
        :default_subject => default_subject,
        :default_body => default_body,
        :allow_editing => false)

      ask.take_action(user, {
        :subject => "User Provided Subject",
        :body => "User Provided Body"
      }, @page)

      user_email = UserEmail.where(:user_id => user.id, :content_module_id => ask.id).all.first
      user_email.subject.should eql default_subject
      user_email.body.should match /#{default_body}/

      ActionMailer::Base.deliveries.size.should == 1
      ActionMailer::Base.deliveries.first.should have_subject(default_subject)
      ActionMailer::Base.deliveries.first.parts.last.body.to_s.should match /#{default_body}/
    end

    it "should cc user" do
      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:email_targets_module)

      ask.take_action(user, {:cc_me => true}, @page)

      user_email = UserEmail.where(:user_id => user.id, :content_module_id => ask.id).first
      user_email.cc_me.should be_true
      ActionMailer::Base.deliveries.size.should == 2
    end
  end

  describe "converting to JSON" do
    it "should not include the email address of the decision makers" do
      ask = FactoryGirl.create(:email_targets_module,
          :targets => "\"Bond, James Bond\" <jbond@mi6.co.uk>, 'Clark Kent, journalist' <ckent@dailyplanet.com>")

      json = ActiveSupport::JSON.decode(ask.to_json)
      json['options']['targets_names'].should eql ["Bond, James Bond", "Clark Kent, journalist"]
      json['options']['targets_emails'].should be_nil
      json['options']['targets'].should be_nil
      ask.targets.should eql "\"Bond, James Bond\" <jbond@mi6.co.uk>, 'Clark Kent, journalist' <ckent@dailyplanet.com>"
    end

    it "should include the number of emails that have been sent through the module" do
      user1 = FactoryGirl.create(:user, :email => 'noone1@example.com')
      user2 = FactoryGirl.create(:user, :email => 'noone2@example.com')
      ask = FactoryGirl.create(:email_targets_module,
          :emails_goal => 100,
          :pages => [@page],
          :targets => "\"Bond, James Bond\" <jbond@mi6.co.uk>, 'Clark Kent, journalist' <ckent@dailyplanet.com>")
      ask.take_action(user1, {}, @page)
      ask.take_action(user2, {}, @page)

      json = ActiveSupport::JSON.decode(ask.to_json)

      json['emails_sent'].should eql 4
      json['options']['emails_goal'].should eql 100
    end

    it_should_behave_like "content module with disabled content", :email_targets_module
  end
end
