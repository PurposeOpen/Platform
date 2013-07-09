require "spec_helper"

describe Api::EmailTrackingController do
  describe "email_opened" do

    before do
      @movement = FactoryGirl.create(:movement)
    end

    it "returns a status code of 400 with no data passed" do
      response = get :email_opened, :movement_id => @movement.id
      response.status.should == 400
    end

    it "returns a status code of 400 with non-base64 encoded data passed" do
      response = get :email_opened, :movement_id => @movement.id, :t => "borked"
      response.status.should == 400
    end

    it "records an email viewed! user activity event against the specified user" do
      @user = FactoryGirl.create(:user)
      @email = FactoryGirl.create(:email)
      hash = EmailTrackingHash.new(@email, @user)

      UserActivityEvent.should_receive(:email_viewed!).with(@user, @email)
      get :email_opened, :movement_id => @movement.id, :t => hash.encode
    end
  end

  describe "email_clicked" do
    before do
      @movement = FactoryGirl.create(:movement)
    end

    it "returns a status code of 400 with no data passed" do
      response = get :email_opened, :movement_id => @movement.id
      response.status.should == 400
    end

    it "returns a status code of 400 with non-base64 encoded data passed" do
      response = get :email_opened, :movement_id => @movement.id, :t => "borked"
      response.status.should == 400
    end

    it "records an email clicked! user activity event against an action page" do
      @user = FactoryGirl.create(:user)
      @email = FactoryGirl.create(:email)
      hash = EmailTrackingHash.new(@email, @user)
      @campaign = FactoryGirl.create(:campaign, :movement => @movement)
      @action_sequence = FactoryGirl.create(:action_sequence, :campaign => @campaign)
      @page = FactoryGirl.create(:action_page, :action_sequence => @action_sequence, :name => "Pretty page")

      UserActivityEvent.should_receive(:email_clicked!).with(@user, @email, @page)
      post :email_clicked, :movement_id => @movement.id, :page_type => "ActionPage", :page_id => @page.friendly_id, :t => hash.encode
    end

    it "records an email clicked! user activity event against a content page" do
      @user = FactoryGirl.create(:user)
      @email = FactoryGirl.create(:email)
      hash = EmailTrackingHash.new(@email, @user)
      @content_page_collection = FactoryGirl.create(:content_page_collection, :movement => @movement)
      @page = FactoryGirl.create(:content_page, :content_page_collection => @content_page_collection, :name => "About")

      UserActivityEvent.should_receive(:email_clicked!).with(@user, @email, @page)
      post :email_clicked, :movement_id => @movement.id, :page_type => "ContentPage", :page_id => @page.friendly_id, :t => hash.encode
    end

    it "records an email clicked! user activity event against the home page" do
      @user = FactoryGirl.create(:user)
      @email = FactoryGirl.create(:email)
      hash = EmailTrackingHash.new(@email, @user)

      UserActivityEvent.should_receive(:email_clicked!).with(@user, @email, nil)
      post :email_clicked, :movement_id => @movement.id, :page_type => "Homepage", :t => hash.encode
    end
  end
end
