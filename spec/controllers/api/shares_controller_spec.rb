require "spec_helper"

describe Api::SharesController do

  before do
    @movement = FactoryGirl.create(:movement)
  end

  describe 'create' do
    before(:each) do
      @page = create(:action_page)
      tell_a_friend_module = create(:tell_a_friend_module)
      create(:content_module_link, :page => @page, :content_module => tell_a_friend_module)
      @user = create(:user)
    end

    shared_examples_for "creating a share" do |share_type|
      it "should create a share for #{share_type}" do
        post :create, :page_id          => @page.id,
                      :movement_id => @movement.id,
                      :user_id            => @user.id,
                      :share_type         => share_type

        response.status.should == 201

        Share.count.should == 1
        share = Share.first
        share.page_id.should == @page.id
        share.user_id.should == @user.id
        share.share_type.should == share_type
      end
    end

    Share::SHARE_TYPES.each {|share_type| it_should_behave_like "creating a share", share_type }
    
    it 'should return 400 when a nil page is passed to create a share' do
      post :create, :page_id          => nil,
                  :movement_id => @movement.id,
                  :user_id            => @user.id,
                  :share_type         => Share::FACEBOOK

      response.status.should == 400
    end

    it 'should should create a share with a nil user' do
      post :create, :page_id        => @page.id,
                    :movement_id => @movement.id,
                    :user_id            => nil,
                    :share_type         => Share::FACEBOOK

      response.status.should == 201
    end

    it 'should not create a share when the page passed is not a tell a friend' do
      page_without_taf = create(:action_page)
      petition_module = create(:petition_module)
      create(:content_module_link, :page => page_without_taf, :content_module => petition_module)
      post :create, :page_id        => page_without_taf.id,
                    :movement_id => @movement.id,
                    :user_id            => @user.id,
                    :share_type         => Share::FACEBOOK

      response.status.should == 400
    end
  end
end