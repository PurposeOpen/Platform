require 'spec_helper'

describe Api::BaseController do
  class Api::BaseController
    def create; render :text => ""; end
    def index; render :text => "gotten"; end
  end

  def perform_request
    with_routing do |map|
      map.draw do 
        post 'api/movements/(:movement_id)/members(.:format)' => 'api/base#create'
        get 'api/movements/(:movement_id)' => 'api/base#index'
      end
      yield
    end
  end

  before do 
    french = FactoryGirl.create(:french)
    english = FactoryGirl.create(:english)
    portuguese = FactoryGirl.create(:portuguese)
    @movement = FactoryGirl.create(:movement, :languages => [french, portuguese, english])
    @movement.default_language = portuguese
    @movement.save!
  end

  it "should fail with 404 if the movement can't be found" do
    perform_request do
      post :create, :member => {:email => "lemmy@kilmister.com"}, :format => :json

      response.status.should == 404
    end
  end

  it "should default to the movement's default language if there is no locale in the request" do
    perform_request do
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

      I18n.locale.should eql :pt
    end
  end

  it "should deny access if authentication enabled and request unauthenticated" do
    perform_request do
      AppConstants.stub!(:authenticate_api_calls).and_return "true"
      get :index, :movement_id => @movement.id
      response.status.should == 401
    end
  end

  it "should grant access if authentication enabled and request authenticated" do
    perform_request do
      AppConstants.stub!(:authenticate_api_calls).and_return "true"
      @movement.password = "foo"
      @movement.password_confirmation = "foo"
      @movement.save!
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@movement.id, "foo")

      get :index, :movement_id => @movement.id

      response.should be_success
    end
  end

  context "setting locale" do
    it "should default locale to the one given in the request if it exists" do
      perform_request do
        post :create, :locale => 'fr', :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

        I18n.locale.should eql :fr
      end
    end

    it "should use movement's default locale if the locale specified in the params is not supported by the movement" do
      perform_request do
        post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json, :locale => "sw"

        I18n.locale.should eql :pt
      end
    end
  end
end
