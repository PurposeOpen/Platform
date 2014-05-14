require "spec_helper"

describe Admin::MovementsController do
  include Devise::TestHelpers

  before :each do
    @movement             = FactoryGirl.create(:movement, name: "This is a Movement")
    @admin_user           = FactoryGirl.create(:platform_user, is_admin: true)
    request.env['warden'] = mock(Warden, authenticate: @admin_user, authenticate!: @admin_user)
  end

  describe "responding to POST create" do
    describe "with valid params" do
      before do
        @english = FactoryGirl.create(:english)
      end
      it "should create a movement and redirect to its admin page" do
        post :create, movement: {name: "movimentum",languages: [@english.id], default_language: @english.id, url: "http://movimentum.com"}
        @movement = assigns(:movement)
        @movement.should_not be_new_record
        response.should redirect_to(admin_movement_path(@movement))
      end

      it "should associate new languages and image settings with the movement" do
        portuguese = FactoryGirl.create(:portuguese)
        post :create, movement: {name: "movimentum", image_settings_attributes: {carousel_image_height: '12', carousel_image_width: "15"}, languages: [@english.id, portuguese.id]}
        @movement = assigns(:movement)

        @movement.languages.size.should eql 2
        @movement.languages.should include(@english, portuguese)
        @movement.image_settings.carousel_image_height.should == 12
        @movement.image_settings.carousel_image_width.should == 15
      end

      it 'should record the admin that created the movement' do
        post :create, movement: {name: "Fruit Bat",languages: [@english.id], default_language: @english.id, url: "http://fruitbat.com"}
        @movement = assigns(:movement)
        @movement.created_by.should == @admin_user.full_name
      end
    end

    describe "with invalid params" do
      it "should not save the movement and re-render the form" do
        post :create, movement: nil
        @movement = assigns(:movement)
        @movement.should be_new_record
        response.should render_template("movements/new")
      end
    end

    describe "responding to PUT update" do
      describe "with valid params" do
        it "should update a movement and redirect to its admin page" do
          put :update, {id: @movement.id, movement: {name: "movere"}}
          @movement.reload
          @movement.name.should == "movere"
          response.should redirect_to(admin_movement_path(@movement))
        end

        it "should associate new languages with the movement" do
          english = FactoryGirl.create(:english)

          put :update, {id: @movement.id, movement: {name: "movere", languages: [english.id]}}

          @movement.reload
          @movement.languages.size.should eql 1
          @movement.languages.should include(english)
        end

        it 'should record the admin that updated the movement' do
          put :update, {id: @movement.id, movement: {name: "movere"}}
          @movement.reload
          @movement.updated_by.should == @admin_user.full_name
        end
      end

      describe "with invalid params" do
        it "should not save the movement and re-render the form" do
          put :update, {id: @movement.id, movement: {name: ""}}
          response.should render_template("movements/edit")
        end
      end
    end
  end

  describe "responding to GET show" do
    it "should load the movement" do
      platform_user = create(:platform_user, is_admin: false)
      create(:user_affiliation, movement_id: @movement.id, user_id: platform_user.id, role: UserAffiliation::ADMIN)
      request.env['warden'] = mock(Warden, authenticate: platform_user, authenticate!: platform_user)

      get :show, id: @movement.id
      response.should be_ok
      assigns[:movement].should == @movement
    end

    it "should authorize the movement" do
      platform_user = create(:platform_user, is_admin: false)
      another_movement = create(:movement, name: "Save the tigers!")
      create(:user_affiliation, movement_id: another_movement.id, user_id: platform_user.id, role: UserAffiliation::ADMIN)
      request.env['warden'] = mock(Warden, authenticate: platform_user, authenticate!: platform_user)

      get :show, id: @movement.id
      response.should be_not_found
    end
  end
end

