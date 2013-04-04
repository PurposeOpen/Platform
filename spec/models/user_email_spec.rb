# == Schema Information
#
# Table name: user_emails
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  content_module_id :integer          not null
#  subject           :string(255)      not null
#  body              :text             default(""), not null
#  targets           :text             default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  page_id           :integer          not null
#  email_id          :integer
#  cc_me             :boolean
#

require "spec_helper"

describe UserEmail do
  def expect_email_send(args)
    email_double = double
    email_double.should_receive(:deliver)

    Emailer.should_receive(:target_email).
        with(args[:movement], args[:targets], args[:from], args[:subject], args[:body]).
        and_return(email_double)
  end

  def expect_email_not_send(args)
    Emailer.should_not_receive(:target_email).
        with(args[:movement], args[:targets], args[:from], args[:subject], args[:body])
  end

  before do
    @user = FactoryGirl.create(:user, :email => 'noone@example.com')
    @cm = FactoryGirl.create(:email_targets_module)
    @page = FactoryGirl.create(:action_page)
  end

  describe "validation" do
    it "requires all its fields to be valid" do
      UserEmail.new(:content_module => @cm, :action_page => @page, :user => @user, :subject => "Subject", :body => "Body", :targets => "mrbob@escobar.com").should be_valid
      UserEmail.new(:content_module => @cm, :action_page => @page, :user => @user, :body => "Body", :targets => "mrbob@escobar.com").should_not be_valid
      UserEmail.new(:content_module => @cm, :action_page => @page, :user => @user, :subject => "Subject", :targets => "mrbob@escobar.com").should_not be_valid
      UserEmail.new(:content_module => @cm, :action_page => @page, :user => @user, :subject => "Subject", :body => "Body").should_not be_valid
    end
  end

  describe "emails" do
    it "creates a sensible email" do
      expect_email_send(:movement => @page.movement, :targets => "bob@bobson.com, mrsanchez@gomez.com", :from => "noone@example.com", :subject => "Booyah", :body => "Put down the stapler Milton", :cc_me => false)

      user_email = UserEmail.new(:user => @user, :subject => "Booyah", :body => "Put down the stapler Milton", :targets => "bob@bobson.com, mrsanchez@gomez.com", :content_module => @cm, :page => @page)

      user_email.send!
    end
    
    it "creates a user activity event" do
      UserActivityEvent.should_receive(:action_taken!).with(@user, @page, @cm, an_instance_of(UserEmail), nil, nil)
      UserEmail.create!(:user => @user, :action_page => @page, :content_module => @cm, :subject => "Booyah", :body => "Put down the stapler Milton", :targets => "bob@bobson.com, mrsanchez@gomez.com")
    end

    it "should send a copy to the user when he/she has opted to receive a copy of the email" do
      expect_email_send(:movement => @page.movement, :targets => "bob@bobson.com, mrsanchez@gomez.com",
          :from => "noone@example.com",
          :subject => "Booyah",
          :body => "Put down the stapler Milton")
      expect_email_send(:movement => @page.movement, :targets => "noone@example.com",
          :from => "noone@example.com",
          :subject => "Booyah",
          :body => "Put down the stapler Milton")

      email = UserEmail.create!(:user => @user, :action_page => @page, :content_module => @cm,
          :subject => "Booyah", :body => "Put down the stapler Milton",
          :targets => "bob@bobson.com, mrsanchez@gomez.com",
          :cc_me => true)
      email.send!
    end

    it "does not send a copy to the user when he/she has not opted to receive a copy of the email" do
      expect_email_not_send(:movement => @page.movement, :targets => "noone@example.com",
          :from => "noone@example.com",
          :subject => "Booyah",
          :body => "Put down the stapler Milton")
      expect_email_send(:movement => @page.movement, :targets => "bob@bobson.com, mrsanchez@gomez.com",
          :from => "noone@example.com",
          :subject => "Booyah",
          :body => "Put down the stapler Milton")

      email = UserEmail.create!(:user => @user, :action_page => @page, :content_module => @cm,
          :subject => "Booyah", :body => "Put down the stapler Milton",
          :targets => "bob@bobson.com, mrsanchez@gomez.com",
          :cc_me => false)
      email.send!
    end
  end
end
