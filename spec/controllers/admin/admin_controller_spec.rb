require 'spec_helper'

describe Admin::AdminController do
  class Admin::AdminController
    skip_authorize_resource
    skip_authorization_check
    def index; head :ok end
  end

  def perform_request
    with_routing do |map|
      map.draw { match 'admin/(:movement_id)' => 'admin/admin#index' }
      yield
    end
  end

  let(:walkfree) { FactoryGirl.create(:movement, :name => 'Walk Free') }
  before do
    login_as FactoryGirl.build(:admin_platform_user)
  end

  it 'loads the movement based on the given movement ID' do
    perform_request do
      get :index, :movement_id => walkfree.id.to_s
      assigns(:movement).should == walkfree
    end
  end

  it 'loads the movement based on the given movement slug' do
    perform_request do
      get :index, :movement_id => walkfree.slug
      assigns(:movement).should == walkfree
    end
  end

  it 'does not load any movement when neither ID or slug is provided' do
    perform_request do
      get :index
      assigns(:movement).should be_nil
    end
  end

  it 'sets the default admin locale to English' do
    perform_request do
      I18n.locale = :pt
      get :index
      I18n.locale.should == :en
    end
  end
end
