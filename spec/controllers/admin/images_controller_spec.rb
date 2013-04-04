require "spec_helper"

describe Admin::ImagesController do
  include Devise::TestHelpers

  before :each do
    request.env['warden'] = mock(Warden, :authenticate => FactoryGirl.create(:user, :is_admin => true),
                                         :authenticate! => FactoryGirl.create(:user, :is_admin => true))

    @allout = FactoryGirl.create(:movement)
    Movement.stub(:find).with(@allout.id).and_return(@allout)
    Movement.stub(:find).with(@allout.id.to_s).and_return(@allout)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get :index, :movement_id => @allout.id
      response.should be_success
    end

    it "should return the images straight from the database if no query string is provided" do
      bunch_of_images = mock(:banners)
      Image.stub_chain(:where, :order, :paginate).and_return(bunch_of_images)

      get :index, :movement_id => @allout.id

      assigns(:images).should eql(bunch_of_images)
    end

    it "should load images based on default search params" do
      get :index, :movement_id => @allout.id, :query => "anything"

      Sunspot.session.should be_a_search_for(Image)
      Sunspot.session.should have_search_params(:order_by, :created_at, :desc)
      Sunspot.session.should have_search_params(:with, :movement_id, @allout.id)
      Sunspot.session.should have_search_params(:paginate, :page => 1, :per_page => Admin::ImagesController::PAGE_SIZE)
    end

    it "should load images based on the query that is in the request" do
      get :index, :movement_id => @allout.id, :query => "footer banner"

      Sunspot.session.should be_a_search_for(Image)
      Sunspot.session.should have_search_params(:keywords, "footer banner")
    end
  end

  describe "POST 'create'" do
    it "should upload successfully and redirect to image page" do
      image = FactoryGirl.create(:image)
      Image.stub(:new).and_return(image)

      post :create, :image =>{}, :movement_id => @allout.id
      assigns(:new_image).should eql(image)
      response.should redirect_to(admin_movement_image_path(@allout, image))
    end

    it "should associate with a movement" do
      image_attributes = {:image_file_name => "banner.jpg"}

      post :create, :image => image_attributes, :movement_id => @allout.id
      assigns(:new_image).movement_id.should == @allout.id
    end

    it 'should render html response for ajax request' do
      image_attributes = {:image_file_name => "banner.jpg"}
      xhr :post, :create, :image => image_attributes, :movement_id => @allout.id
      assigns(:new_image).movement_id.should == @allout.id
      response.should render_template(:create)
    end

    it 'should render error response when ajax request fails' do
      xhr :post, :create, :image => {}, :movement_id => @allout.id
      assigns(:new_image).movement_id.should == @allout.id
      response.status.should == 400
    end
  end
end
