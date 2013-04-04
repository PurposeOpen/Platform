require "spec_helper"

describe Admin::DownloadableAssetsController do
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

    it "should return the downloadable assets that match the search query" do
      bunch_of_downloadable_assets = mock(:guest_list)
      DownloadableAsset.stub_chain(:where, :order, :paginate).and_return(bunch_of_downloadable_assets)

      get :index, :movement_id => @allout.id

      assigns(:assets).should eql(bunch_of_downloadable_assets)
    end

    it "should load downloadable assets based on default search params" do
      get :index, :movement_id => @allout.id, :query => "anything"

      Sunspot.session.should be_a_search_for(DownloadableAsset)
      Sunspot.session.should have_search_params(:order_by, :created_at, :desc)
      Sunspot.session.should have_search_params(:with, :movement_id, @allout.id)
      Sunspot.session.should have_search_params(:paginate, :page => 1, :per_page => Admin::DownloadableAssetsController::PAGE_SIZE)
    end

    it "should load downloadable assets based on the query that is in the request" do
      get :index, :movement_id => @allout.id, :query => "guest list"

      Sunspot.session.should be_a_search_for(DownloadableAsset)
      Sunspot.session.should have_search_params(:keywords, "guest list")
    end
  end

  describe "POST 'create'" do
    it "should upload successfully and redirect to asset page" do
      asset = FactoryGirl.create(:downloadable_asset)
      DownloadableAsset.stub(:new).and_return(asset)

      post :create, :asset =>{}, :movement_id => @allout.id
      assigns(:asset).should eql(asset)
      response.should redirect_to(admin_movement_downloadable_asset_path(@allout, asset))
    end

    it "should associate with a movement" do
      asset_attributes = {:asset_file_name => "foo.txt"}

      post :create, :asset => asset_attributes, :movement_id => @allout.id
      assigns(:asset).movement_id.should == @allout.id
    end
  end
end
