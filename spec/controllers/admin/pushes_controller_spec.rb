require "spec_helper"

describe Admin::PushesController do
  before :each do
    @movement = FactoryGirl.create(:movement)
    @campaign = FactoryGirl.create(:campaign, :movement => @movement)
    @valid_params = {
      :name => "Ceci nes pas une push"
    }
    @push = Push.create!(@valid_params.merge(:campaign => @campaign))
    # mock up an authentication in the underlying warden library
    request.env['warden'] = mock(Warden, :authenticate => FactoryGirl.create(:user, :is_admin => true),
                                         :authenticate! => FactoryGirl.create(:user, :is_admin => true))
  end

  describe "responding to POST create" do
    describe "with valid params" do
      it "should create a push and redirect to its push page" do
        post :create, :movement_id => @movement.id, :campaign_id => @campaign.id, :push => @valid_params
        push = assigns(:push)
        push.should_not be_new_record
        response.should redirect_to(admin_movement_push_path(@movement, push))
      end
    end

    describe "with invalid params" do
      it "should not save the push and re-render the form" do
        post :create, :movement_id => @movement.id, :campaign_id => @campaign.id, :push => nil
        push = assigns(:push)
        push.should be_new_record
        response.should render_template("pushes/new")
      end
    end
  end
  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update an push and redirect to campaign show page" do
        put :update, :id => @push.id, :movement_id => @movement.id, :push => @valid_params.merge(:name => "Something Else")
        @push.reload
        @push.name.should == "Something Else"
        response.should redirect_to(admin_movement_campaign_path(@movement, @campaign))
      end
    end

    describe "with invalid params" do
      it "should not save the push and re-render the form" do
        put :update, :id => @push.id, :movement_id => @movement.id, :push => {:name => ""}
        response.should render_template("pushes/edit")
      end
    end
  end

  describe "responding to DELETE destroy" do
    it "should delete the push and redirect to campaign admin page" do
      delete :destroy, :id => @push.id, :movement_id => @movement.id
      @push.reload
      @push.should be_deleted

      response.should redirect_to(admin_movement_campaign_path(@movement, @push.campaign))
    end
  end

  describe "responding to GET emails" do
    it "should return a json with all emails contained in all blasts in a push" do
      blast1 = create(:blast, :push => @push)
      email1 = create(:email,  :name => "email1", :blast => blast1)


      push2 = Push.create!(@valid_params.merge(:campaign => @campaign))
      blast2 = create(:blast, :push => push2)
      email2 = create(:email, :name =>"email2", :blast => blast2)

      get :emails_for_combo, :id => @push.id, :movement_id => @movement.id
      response.should be_success
      json_response = JSON.parse(response.body)
      json_response.length.should == 1
      json_response[0]["label"].should == email1.name
      json_response[0]["value"].should == email1.id
    end
  end

  describe "responding to GET email_stats_report" do
    it "should render a stats table for all emails within the push" do
      email = FactoryGirl.create(:sent_email)
      get :email_stats_report, :id => email.blast.push.id, :movement_id => @movement.id
      csv = response.body.split("\n")
      csv[0].should == "Id,Created,Sent At,Blast,Email,Sent to,Opens,Opens Percentage,Clicks,Clicks Percentage,Actions Taken,Actions Taken Percentage,New Members,New Members Percentage,Unsubscribed,Unsubscribed Percentage,Spam,Spam Percentage,Total $,Avg. $"
      csv[1].should match /[\d-]+,[\d-]+ [\d:]+ UTC,Dummy Blast Name,Dummy Email Name,0,0,0%,0,0%,0,0%,0,0%,0,0%,0,0%,\$0.00,/
    end
  end
end
