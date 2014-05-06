require "spec_helper"

describe Admin::HomepagesController do
  include Devise::TestHelpers

  before :each do
    request.env['warden'] = mock(Warden, :authenticate => FactoryGirl.create(:user, :is_admin => true),
                                 :authenticate! => FactoryGirl.create(:user, :is_admin => true))
  end

  describe "#edit" do
    it "should assign a single new homepage if no homepage previously exists for that language" do
      movement = FactoryGirl.create(:movement)
      get :edit, :movement_id => movement.id
      assigns(:homepage_contents).size.should == 1
      assigns(:homepage_contents).first.should be_new_record
    end

    it "should retrieve existing homepages if they exist for a language in the movement" do
      fr, pt = FactoryGirl.create(:portuguese, :iso_code => "pt"), FactoryGirl.create(:french, :iso_code => "fr")
      movement = FactoryGirl.create(:movement, :languages => [ fr, pt ])
      FactoryGirl.create(:homepage_content, :language => fr, :homepage => movement.homepage)

      get :edit, :movement_id => movement.id
      assigns(:homepage_contents).map(&:language).map(&:iso_code).should match_array(["fr", "pt"])
      assigns(:homepage_contents).map(&:new_record?).should match_array([ true, false ])
    end
  end

  describe "#show" do
    it "should redirect to the edit homepage for the default locale" do
      english = FactoryGirl.create(:english)
      french = FactoryGirl.create(:french)
      allout = FactoryGirl.create(:movement, :languages => [english, french])
      allout.default_language = english

      get :show, :movement_id => allout.id

      response.should redirect_to(edit_admin_movement_homepages_path(allout))
    end
  end

  describe "#update" do
    before do
      @follow_links = {:facebook => 'facebook_url', :twitter => 'twitter_url', :youtube => 'youtube_url'}
    end
    describe "with an existing homepage" do
      before :each do
      begin
        @english = FactoryGirl.create(:english)
        @allout = FactoryGirl.create(:movement, :languages => [@english])
        @allout.default_language = @english
        @homepage_content_attributes = {:banner_image => "image.jpg", :banner_text => "banner", :follow_links => @follow_links}

        @homepage = Homepage.new(:movement => @allout)
        @homepage_english_content = HomepageContent.new(@homepage_content_attributes.merge :language => @english, :homepage => @homepage)
        @homepage.homepage_contents << @homepage_english_content
        @homepage.save!
      rescue
        raise @homepage.homepage_contents.first.errors.inspect
      end
      end

      it "should update homepage when details change" do
        updated_homepage_attributes = @homepage_content_attributes.merge :banner_text => "footer"

        put :update, :movement_id => @allout.id, :homepage_content => { @english.iso_code => updated_homepage_attributes }

        response.should redirect_to(edit_admin_movement_homepages_path(@allout))
        flash[:notice].should eql("Homepages have been updated.")
        assigns(:homepage_contents).first.banner_text.should eql("footer")
      end
    end

    describe "without an existing homepage" do
      before :each do
        @english = FactoryGirl.create(:english)
        @french = FactoryGirl.create(:french)
        @allout = FactoryGirl.create(:movement, :languages => [@english, @french])
        @allout.default_language = @english
      end

      it "should save and redirect to edit" do
        homepage_attributes = {:banner_image => "image.jpg", :banner_text => "banner", :follow_links => @follow_links}

        post :update, :movement_id => @allout.id, :homepage_content => { @french.iso_code => homepage_attributes }
        response.should redirect_to(edit_admin_movement_homepages_path(@allout))
        flash[:notice].should eql("Homepages have been updated.")
      end
    end
  end

  describe 'preview' do
    it 'should create draft and render preview url' do
      movement = create(:movement)
      homepage = create(:homepage, :movement => movement)
      expect {
        put :create_preview, :movement_id => movement.id, :homepage_content => {:en => {:banner_text => 'banner for preview'}}
      }.to change{movement.reload.draft_homepages.size}.from(0).to(1)
      response.body.should == preview_admin_movement_homepages_path(movement, :draft_homepage_id => movement.draft_homepages.first.id)
    end
  end

  describe 'preview' do
    it 'should render preview page with base layout' do
      movement = create(:movement)
      get :preview, :draft_homepage_id => 23, :movement_id => movement.id
      response.should render_template('layouts/_base')
      response.should render_template(:preview)
    end
  end
end
