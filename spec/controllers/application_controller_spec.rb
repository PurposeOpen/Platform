require 'spec_helper'

describe ApplicationController do
  before(:each) do
    @controller = ApplicationController.new
  end

  it "should build the email tracking hash from the request params" do
    user = FactoryGirl.create(:user)
    email = FactoryGirl.create(:email)
    hash = EmailTrackingHash.new(email, user)

    @controller.stub(:params) { {:t => hash.encode} }
    @controller.email_tracking_hash.should == hash
  end

  it "should tolerate invalid base64 encoding and return nil" do
    @controller.stub(:params) { {:t => "@!#$@"} }
    @controller.email_tracking_hash.email.should be_nil
    @controller.email_tracking_hash.user.should be_nil
  end
end
