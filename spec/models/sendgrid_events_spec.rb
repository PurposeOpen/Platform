require "spec_helper"

describe "SendgridEvents" do

  before(:each) do
    @action_page = FactoryGirl.create(:action_page)
    @movement = @action_page.movement
    @unsubscribe = FactoryGirl.create(:unsubscribe_module, pages: [@action_page])
    @campaign = FactoryGirl.create(:campaign, movement: @movement)
    @push = FactoryGirl.create(:push, campaign: @campaign)
    @blast = FactoryGirl.create(:blast, push: @push)
    @email = FactoryGirl.create(:email, blast: @blast)
    @supporter = FactoryGirl.create(:user,
                                    :email => "bob@example.com",
                                    :movement => @movement, :is_member => true)
  end


  ### Helper functions

  def find_by_email(email)
    User.find_by_email_and_movement_id(email, @movement.id)
  end

  def event(type, email_address, email_id)
    klass =
      case type
      when :processed
          SendgridEvents::Processed
      when :dropped
          SendgridEvents::Dropped
      when :bounce
          SendgridEvents::Bounce
      when :delivered
          SendgridEvents::Delivered
      when :deferred
          SendgridEvents::Deferred
      when :bounce
          SendgridEvents::Bounce
      when :open
          SendgridEvents::Open
      when :click
          SendgridEvents::Click
      when :spamreport
          SendgridEvents::SpamReport
      when :unsubscribe
          SendgridEvents::Unsubscribe
      end
    klass.new(@movement.id, email_address, email_id)
  end

  def event_and_handle(type, email_address: @supporter.email, email_id: @email.id)
    evt = event(type, email_address, email_id)
    result = evt.handle
    expect(result).to be_true
    result
  end

  def event_with_bad_email_address(type)
    bad_email = "dawg@example.com"
    expect(find_by_email(bad_email)).to be_nil
    event_and_handle(type, email_address: bad_email)
  end

  def event_with_bad_email_id(type)
    bad_id = 123456
    expect(Email.where(id: bad_id).count).to eq(0)
    event_and_handle(type, email_id: bad_id)
  end


  ### Specs

  describe "noop" do
    it "does nothing" do
      noop = SendgridEvents::noop
      noop.handle
    end
  end


  describe "::SpamReport" do
    it "unsubscribes the supporter" do
      expect(find_by_email(@supporter.email).is_member).to be_true

      event_and_handle(:spamreport)

      expect(find_by_email(@supporter.email).is_member).to be_false
      expect(UserActivityEvent.unsubscriptions.where(:user_id => @supporter.id).first).to be_true
    end

    it "records spam activity" do
      expect(find_by_email(@supporter.email).is_member).to be_true

      event_and_handle(:spamreport)

      expect(PushSpammedEmail.where(email_id: @email.id, user_id: @supporter.id).first).to be_true
    end

    it "does not fail if the supporter doesn't exist" do
      event_with_bad_email_address(:spamreport)
      expect(PushSpammedEmail.count).to eq(0)
    end

    it "does not fail if the email doesn't exist" do
      event_with_bad_email_id(:spamreport)
      expect(PushSpammedEmail.count).to eq(0)
    end
  end


  describe "::Unsubscribe" do
    it "unsubscribes the supporter" do
      expect(find_by_email(@supporter.email).is_member).to be_true

      event_and_handle(:unsubscribe)

      expect(find_by_email(@supporter.email).is_member).to be_false
      expect(UserActivityEvent.unsubscriptions.where(:user_id => @supporter.id).first).to be_true
    end

    it "does not fail if the supporter doesn't exist" do
      event_with_bad_email_address(:unsubscribe)
      expect(UserActivityEvent.unsubscriptions.where(:user_id => @supporter.id).count).to eq(0)
    end

    it "does not fail if the email doesn't exist" do
      event_with_bad_email_id(:unsubscribe)
      expect(UserActivityEvent.unsubscriptions.where(:user_id => @supporter.id).count).to eq(1)
    end
  end


  describe "::Click" do
    it "records a click" do
      event_and_handle(:click)

      expect(PushClickedEmail.where(email_id: @email.id, user_id: @supporter.id).count).to eq(1)
    end

    it "does not fail if the supporter doesn't exist" do
      event_with_bad_email_address(:click)
      expect(PushClickedEmail.count).to eq(0)
    end

    it "does not fail if the email doesn't exist" do
      event_with_bad_email_id(:click)
      expect(PushClickedEmail.count).to eq(0)
    end
  end


  describe "::Open" do
    it "records a view" do
      event_and_handle(:open)

      expect(PushViewedEmail.where(email_id: @email.id, user_id: @supporter.id).count).to eq(1)
    end

    it "does not fail if the supporter doesn't exist" do
      event_with_bad_email_address(:open)
      expect(PushViewedEmail.count).to eq(0)
    end

    it "does not fail if the email doesn't exist" do
      event_with_bad_email_id(:open)
      expect(PushViewedEmail.count).to eq(0)
    end
  end


  describe "::Bounce" do
    it "unsubscribes the supporter" do
      expect(find_by_email(@supporter.email).is_member).to be_true

      event_and_handle(:bounce)

      expect(find_by_email(@supporter.email).is_member).to be_false
      expect(UserActivityEvent.unsubscriptions.where(:user_id => @supporter.id).first).to be_true
    end

    it "does not fail if the supporter doesn't exist" do
      event_with_bad_email_address(:bounce)
      expect(UserActivityEvent.unsubscriptions.where(:user_id => @supporter.id).count).to eq(0)
    end

    it "does not fail if the email doesn't exist" do
      event_with_bad_email_id(:open)
      expect(UserActivityEvent.unsubscriptions.where(user_id: @supporter.id).count).to eq(0)
    end
  end

end
