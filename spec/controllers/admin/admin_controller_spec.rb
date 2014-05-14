require 'spec_helper'

describe Admin::AdminController do
  class DummyAdminController < Admin::AdminController;
    skip_authorize_resource
    skip_authorization_check
    def index; head :ok end
  end

  let(:walkfree) { FactoryGirl.create(:movement, name: 'Walk Free') }
  before do
    @controller = DummyAdminController.new
    login_as FactoryGirl.build(:admin_platform_user)
  end

  xit 'loads the movement based on the given movement ID' do
    get :index, movement_id: walkfree.id.to_s
    assigns(:movement).should == walkfree
  end

  xit 'loads the movement based on the given movement slug' do
    get :index, movement_id: walkfree.slug
    assigns(:movement).should == walkfree
  end

  xit 'does not load any movement when neither ID or slug is provided' do
    get :index
    assigns(:movement).should be_nil
  end

  xit 'sets the default admin locale to English' do
    I18n.locale = :pt
    get :index
    I18n.locale.should == :en
  end
end
