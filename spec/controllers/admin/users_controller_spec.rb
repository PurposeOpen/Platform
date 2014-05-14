require "spec_helper"

describe Admin::UsersController do
  include Devise::TestHelpers # to give your spec access to helpers

  before { Delayed::Worker.delay_jobs = false } # TODO Enable this globally. Never execute async in tests.

  before :each do
    @user = FactoryGirl.create(:platform_user, first_name: "Test", last_name: "User")

    @movement = FactoryGirl.create(:movement)    
    # mock up an authentication in the underlying warden library
    request.env['warden'] = mock(Warden, authenticate: FactoryGirl.create(:platform_user, is_admin: true),
                                         authenticate!: FactoryGirl.create(:platform_user, is_admin: true))
  end

  describe "responding to GET index" do
    it "should query solr to display all users paginated" do
      get :index, movement_id:@movement.id 
      Sunspot.session.should be_a_search_for(PlatformUser)
      Sunspot.session.should have_search_params(:paginate, page: 1, per_page: Admin::UsersController::PAGE_SIZE)
    end
    it "should query solr to display paginated search results with a keyword specified" do
      get :index, query: "KittenS", movement_id:@movement.id 
      Sunspot.session.should be_a_search_for(PlatformUser)
      Sunspot.session.should have_search_params(:keywords, "KittenS")
    end
    it "should query solr to display admins only if the checkbox is selected" do
      get :index, admins_only: "admins_only", movement_id:@movement.id 
      Sunspot.session.should be_a_search_for(PlatformUser)
      Sunspot.session.should have_search_params(:with, :is_admin, 1)
    end
  end

  describe "responding to POST create" do
    describe "with valid params" do
      it "should create a user and redirect to the index page" do
        movement = FactoryGirl.create(:movement)
        post :create, movement_id: movement.id, user: {
          email: "hello@kittypetition.org", 
          first_name: "Hello", 
          last_name: "Kitty",
          user_affiliations_attributes: {
            "0" => {
              movement_id: movement.id,
              role: "",
              id: nil
        }}}

        @user = assigns(:user)
        @user.should_not be_new_record
        response.should redirect_to(admin_movement_users_path(movement))
      end

      it "should create a user and his associated affiliations" do
        movement = FactoryGirl.create(:movement)
        post :create, movement_id: movement.id, user: {
          email: "hello@kittypetition.org",
          first_name: "Hello",
          last_name: "Kitty",
          user_affiliations_attributes: {
            "0" => { 
              movement_id: movement.id, 
              role:"campaigner", id:nil
        }}}

        @user = assigns(:user)
        @user.should_not be_new_record
        @user.user_affiliations.size.should eql 1
        response.should redirect_to(admin_movement_users_path(movement))
      end
    end

    describe "with invalid params" do
      it "should not save the user and re-render the form" do
        post :create, user: nil, movement_id:@movement.id 
        @user = assigns(:user)
        @user.should be_new_record
        response.should render_template("users/new")
      end
    end

    describe "responding to PUT update" do
      describe "with valid params" do
        it "should update a user and redirect to the index page" do
          movement = FactoryGirl.create(:movement)
          put :update, movement_id: movement.id, id: @user.id, user: { email: "hello@kittypetition.org" }
          @user.reload
          @user.email.should == "hello@kittypetition.org"
          response.should redirect_to(admin_movement_users_path(movement))
        end
      end

      describe "with invalid params" do
        it "should not save the user and re-render the form" do
          put :update, {id: @user.id, movement_id:@movement.id , user: {email: ""}}
          response.should render_template("users/edit")
        end
      end

      describe "when editing myself" do
        it "should not allow changes to any of the user's attributes" do
          user = FactoryGirl.create(:platform_user, email: "theuser@yourdomain.com", is_admin: true)
          login_as user

          put :update, {id: user.id, movement_id:@movement.id , user: {email: "theuser@yourdomain.com"}}

          user.reload
          user.email.should eql "theuser@yourdomain.com"
        end
      end
    end
  end

  describe "responding to DELETE destroy" do
    it "should delete the user then redirect to users index" do
      movement = FactoryGirl.create(:movement)
      delete :destroy, movement_id: movement.id, id: @user.id
      @user.reload
      @user.should be_deleted
      response.should redirect_to(admin_movement_users_path(movement))
    end
  end

  describe "changing roles" do
    it "should change roles if current user is admin" do
      request.env['warden'] = mock(Warden, authenticate: FactoryGirl.create(:platform_user, is_admin: true),
                                           authenticate!: FactoryGirl.create(:platform_user, is_admin: true))

      post :create, movement_id:@movement.id, user: {email: "hello@kittypetition.org", first_name: "Hello", last_name: "Kitty",
                              is_admin: true}
      user = assigns(:user).reload
      user.should be_is_admin

      user.update_attributes!(is_admin: false)

      put :update, id: user.id, movement_id:@movement.id , user: {email: "hello@kittypetition.org", is_admin: true}
      user = assigns(:user).reload
      user.should be_is_admin
    end

    it "should remove roles from a movement user" do
      movement = FactoryGirl.create(:movement)
      user = FactoryGirl.create(:platform_user)
      user_affiliation = UserAffiliation.create(movement_id: movement.id, user_id: user.id, role: "campaigner")
      user.user_affiliations = [user_affiliation]
      user.save

      user.reload
      user.user_affiliations.size.should eql 1

      put :update, {movement_id:movement.id, user: {"user_affiliations_attributes"=>{"0"=>{"movement_id"=>movement.id, "role"=>"", "id"=>user_affiliation}}}, "id"=>user.id}

      user.reload
      user.user_affiliations.size.should eql 0
    end
  end
end
