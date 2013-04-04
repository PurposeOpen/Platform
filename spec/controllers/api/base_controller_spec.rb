require 'spec_helper'

describe Api::BaseController do
  class TestBaseController < Api::BaseController
    def create; render :text => ""; end
    def index; render :text => "gotten"; end
  end

  before do 
    @controller = TestBaseController.new
    french = FactoryGirl.create(:french)
    english = FactoryGirl.create(:english)
    portuguese = FactoryGirl.create(:portuguese)
    @movement = FactoryGirl.create(:movement, :languages => [french, portuguese, english])
    @movement.default_language = portuguese
    @movement.save!
  end

pending do 
  it "should fail with 404 if the movement can't be found" do
    post :create, :member => {:email => "lemmy@kilmister.com"}, :format => :json

    response.status.should == 404
  end

  it "should default to the movement's default language if there is no locale in the request" do
    post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

    I18n.locale.should eql :pt
  end

  it "should deny access if authentication enabled and request unauthenticated" do
    AppConstants.stub!(:authenticate_api_calls).and_return "true"
    get :index, :movement_id => @movement.id
    response.status.should == 401
  end

  it "should grant access if authentication enabled and request authenticated" do
    AppConstants.stub!(:authenticate_api_calls).and_return "true"
    @movement.password = "foo"
    @movement.password_confirmation = "foo"
    @movement.save!
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@movement.id, "foo")

    get :index, :movement_id => @movement.id

    response.should be_success
  end

  context "setting locale" do
    it "should default locale to the one given in the request if it exists" do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

      I18n.locale.should eql :fr
    end

    it "should default locale to the locale value in params if request does not contain it" do
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :locale => 'fr', :format => :json

      I18n.locale.should eql :fr
    end

    it "should default locale to movement's default if request and params do not contain locale information" do
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

      I18n.locale.should eql :pt
    end

    it "should use movement's default locale if the locale specified in the params is not supported by the movement" do
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json, :locale => "sw"

      I18n.locale.should eql :pt
    end

    it "should use locale specified in a list of accepted languages" do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-US,en,q=0.8'
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

      I18n.locale.should eql :en
    end

    it "should use movement's default locale if the request accepts any language" do
      request.env['HTTP_ACCEPT_LANGUAGE'] = '*'
      post :create, :member => {:email => "lemmy@kilmister.com"}, :movement_id => @movement.id, :format => :json

      I18n.locale.should eql :pt
    end
  end
  end
end
