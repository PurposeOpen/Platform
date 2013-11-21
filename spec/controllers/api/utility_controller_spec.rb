require "spec_helper"

describe Api::UtilityController do
  before do
    @movement = FactoryGirl.create(:movement)
  end

  describe "unsubscribe_permanently" do

    before(:each) do
      @user = create(:user)
    end
    it "should unsubscribe an email that's posted with the param email" do
      post :unsubscribe_permanently, :email => @user.email
      response.status.should == 201
      @user.reload
      @user.permanently_unsubscribed?.should == true
    end

    it "should not unsubscribe an email posted with any parameter besides email" do
      post :unsubscribe_permanently, :not_email => @user.email
      response.status.should == 200
      @user.reload
      @user.permanently_unsubscribed?.should == false
    end
  end
end
