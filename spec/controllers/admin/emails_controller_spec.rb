require "spec_helper"

describe Admin::EmailsController do

  before :each do
    @blast = FactoryGirl.create(:blast)
    @movement = @blast.push.campaign.movement
    @valid_params = {
      name: "Hello",
      from: "Is it me you are looking for <lrichie@yourdomain.org>",
      reply_to: 'coconut@bongos.com',
      subject: "This is the subject",
      body: "This is the body",
      language_id: @movement.default_language.id
    }
    @email = FactoryGirl.create(:email, @valid_params.merge(blast: @blast))
    # mock up an authentication in the underlying warden library
    request.env['warden'] = mock(Warden, authenticate: FactoryGirl.create(:user, is_admin: true),
                                         authenticate!: FactoryGirl.create(:user, is_admin: true))

  end

  describe "responding to POST create" do
    describe "with valid params" do
      it "should create an email and redirect to its edit page" do
        post :create, blast_id: @blast.id, email: @valid_params, movement_id: @movement.id
        email = assigns(:email)
        email.should_not be_new_record
        response.should redirect_to(edit_admin_movement_email_path(@movement, email))
      end

      it "should dispatch a test email" do
        test_recipients = ["test1@example.com", "test2@example.com"]
        email = Email.new(@valid_params.merge(blast: @blast))
        Email.stub(:new) {email}
        email.should_receive(:send_test!).with(test_recipients)

        post :create, blast_id: @blast.id, movement_id: @movement.id, email: @valid_params, save_send: true, test_recipients: test_recipients.join(',')
      end
    end

    describe "with invalid params" do
      it "should not save the email and re-render the form" do
        post :create, blast_id: @blast.id, movement_id: @movement.id, email: nil
        email = assigns(:email)
        email.should be_new_record
        response.should render_template("emails/new")
      end

      it "should not send the email if it hasn't been created" do
        post :create, blast_id: @blast.id, movement_id: @movement.id, email: nil, test_recipients: "me@me.com"
        email = assigns(:email)
        email.should be_new_record
        response.should render_template("emails/new")
      end
    end
  end

  describe "responding to PUT update" do
    describe "with valid params" do
      it "should update an email and redirect to its edit page" do
        put :update, id: @email.id, movement_id: @movement.id,
            email: @valid_params.merge(name: "Something Else")
        @email.reload
        @email.name.should == "Something Else"
        @email.reply_to.should == 'coconut@bongos.com'
        response.should redirect_to(edit_admin_movement_email_path(@movement, @email))
      end

      it "should redirect to its pushes page when proof recipient is present" do
        put :update, id: @email.id, movement_id: @movement.id, email: @valid_params.merge(name: "Something Else"), save_send: true, test_recipients: "proof@yourdomain.org"
        response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      end
    end

    it "should dispatch a test email" do
      test_recipients = ["test1@example.com", "test2@example.com"]
      Email.stub(:find) { @email }
      @email.should_receive(:send_test!).with(test_recipients)

      put :update, id: @email.id, movement_id: @movement.id, email: @valid_params.merge(name: "Something Else"), save_send: true, test_recipients: test_recipients.join(',')
    end

    it "should clear test timestamp if updating email without sending a test" do
      Email.stub(:find) { @email }
      @email.should_receive(:clear_test_timestamp!)

      put :update, id: @email.id, movement_id: @movement.id, email: @valid_params.merge(name: "Something Else")
    end

    describe "with invalid params" do
      it "should not save the email and re-render the form" do
        put :update, id: @email.id, movement_id: @movement.id, email: {name: ""}
        response.should render_template("emails/edit")
      end
    end
  end

  describe "responding to DELETE destroy" do
    it "should delete the email and redirect to push admin page" do
      delete :destroy, id: @email.id, movement_id: @movement.id
      @email.reload
      @email.should be_deleted
      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
    end
  end

  describe "responding to GET index given a push" do
    it "should return a JSON response listing all emails associated to the given push" do
      get :index, push_id: @blast.push.id, movement_id: @movement.id, blast_id: @blast.id, format: :json
      response.should be_success
      body = JSON.parse(response.body)
      body.length.should == 1
      body[0]["label"].should == @email.name
      body[0]["value"].should == @email.id
    end
  end

  describe "clone email" do
    it "should copy selected fields from existing email to new email object" do
      get :clone, blast_id: @blast.id, movement_id: @movement.id, email_id: @email.id
      response.should render_template("emails/new")
      assigns[:email][:name].should be_nil
      assigns[:email][:language_id].should == @email.language_id
      assigns[:email][:from].should == @email.from
      assigns[:email][:reply_to].should == @email.reply_to
      assigns[:email][:subject].should == @email.subject
      assigns[:email][:body].should == @email.body
      assigns[:email][:blast_id].should == @email.blast_id
    end
  end

  describe "responding to POST cancel" do
    before do
      Email.stub(:find) { @email }
    end

    it "should cancel jobs belonging to the given blast" do
      @email.should_receive(:cancel_schedule).and_return(true)

      post :cancel_schedule, email_id: @email.id, blast_id: @blast.id, movement_id:@movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:notice].should == "Delivery canceled"
    end

    it "should redirect to the push page with the appropriate message if jobs couldn't be canceled" do
      @email.should_receive(:cancel_schedule).and_return(false)

      post :cancel_schedule, email_id: @email.id, blast_id: @blast.id, movement_id:@movement.id

      response.should redirect_to(admin_movement_push_path(@movement, @blast.push))
      flash[:notice].should == "No deliveries in progress to be canceled"
    end
  end
end
