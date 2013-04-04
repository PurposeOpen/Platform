require "spec_helper"

describe EmailTrackingFieldHelper do

  it "should read params and output hidden tag for tracking" do
    helper.stub!(:params).and_return({:t =>"z"})
    helper.email_tracking_field.should == "<input type=\"hidden\" name=\"t\" value =\"z\">"
  end

  it "should return an empty string if there is no t param" do
    helper.stub!(:params).and_return({:not_t => "N/A" })
    helper.email_tracking_field.should be_nil
  end

end
