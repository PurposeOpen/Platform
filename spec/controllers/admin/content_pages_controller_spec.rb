require 'spec_helper'

describe Admin::ContentPagesController do

  before(:each) do
    admin = FactoryGirl.create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => admin, :authenticate! => admin)

    @movement = FactoryGirl.create(:movement)
    @movement.default_language = @movement.languages.first
    @movement.movement_locales.create!(:language => FactoryGirl.create(:portuguese), :default => false)

    @footer_bucket = FactoryGirl.create(:content_page_collection, :name => 'Footer', :movement => @movement)
    FactoryGirl.create(:content_page, :name => "Zzzzz I'm sleepy'", :content_page_collection => @footer_bucket)
    FactoryGirl.create(:content_page, :name => "Dude, this is awesome!'", :content_page_collection => @footer_bucket)
    FactoryGirl.create(:content_page, :name => "Great Scott!'", :content_page_collection => @footer_bucket)

    @jobs_bucket = FactoryGirl.create(:content_page_collection, :name => 'Jobs', :movement => @movement)
    @movement.content_page_collections = [ @footer_bucket, @jobs_bucket ]
  end

  describe "#index" do
    it "should retrieve all content page collections" do
      get :index, :movement_id => @movement.id

      assigns(:content_page_collections).should include @footer_bucket, @jobs_bucket
    end

    it "should show the content pages alphabetically sorted in each content page collection" do
      get :index, :movement_id => @movement.id

      assigns(:content_page_collections).first.content_pages.map(&:name).should eql ["Dude, this is awesome!'", "Great Scott!'", "Zzzzz I'm sleepy'"]
    end
  end

  describe "#new" do
    it "should provide an empty content page associated with the provided collection so it can be filled in" do
      get :new, :movement_id => @movement.id, :content_page_collection_id => @footer_bucket.id

      new_content_page = assigns(:content_page)
      new_content_page.should_not be_nil
      new_content_page.content_page_collection_id.should eql @footer_bucket.id
    end
  end

  describe "#create" do
    it "should persist the provided content page" do
      post :create, :content_page => {:name => "About"}, :content_page_collection_id => @footer_bucket.id, :movement_id => @movement.id
      assigns(:content_page).should be_persisted
    end

    it "should redirect to #edit page" do
      post :create, :content_page => {:name => "About1234-4567-342"}, :content_page_collection_id => @footer_bucket.id, :movement_id => @movement.id
      content_page = ContentPage.where(:movement_id => @movement.id, :name => "About1234-4567-342").first
      content_page.should_not be_nil
      response.should redirect_to edit_admin_movement_content_page_path(@movement, content_page)
    end
  end

  describe "#edit" do
    before do
      @allout = FactoryGirl.create(:movement, :name => "AllOut")
      @walkfree = FactoryGirl.create(:movement, :name => "WalkFree")

      @allout_collection = FactoryGirl.create(:content_page_collection, :movement => @allout)
      @walkfree_collection = FactoryGirl.create(:content_page_collection, :movement => @walkfree)

      @allout_jobs = FactoryGirl.create(:content_page, :name => "Jobs", :content_page_collection => @allout_collection)
      @walkfree_jobs = FactoryGirl.create(:content_page, :name => "Jobs", :content_page_collection => @walkfree_collection)
    end

    context "two movements have content pages with the same name" do
      it "should make the content page available" do
        content_page = FactoryGirl.create(:content_page)
        get :edit, :id => content_page.id, :movement_id => content_page.movement.id

        assigns(:content_page).should eql content_page
      end

      it "should find AllOut's job page" do
        get :edit, :movement_id => "allout", :id => "jobs"
        assigns(:content_page).id.should eql @allout_jobs.id
      end

      it "should find WalkFree's job page" do
        get :edit, :movement_id => "walkfree", :id => "jobs"
        assigns(:content_page).id.should eql @walkfree_jobs.id
      end
    end
  end

  describe "#update" do
    before do
      @about_page_content = FactoryGirl.create(:accordion_module)
      @about_page = FactoryGirl.create(:content_page, :name => "About", :content_page_collection => @jobs_bucket)
      @about_page.content_module_links.create!(:layout_container => ContentModule::MAIN, :content_module => @about_page_content)
    end

    it "should update the content page and its underlying content modules" do
      put :update, :movement_id => @movement.id, :id => @about_page.id, :content_page => { :name => "Contact Us"}, :content_modules => {
          @about_page_content.id => { :title => "Address", :content => "Our address is..." }}

      contact_us_page = ContentPage.find(@about_page.id)
      contact_us_page.name.should eql "Contact Us"
      contact_us_page.content_modules.first.title.should eql "Address"
      contact_us_page.content_modules.first.content.should eql "Our address is..."
    end

    context "content modules per container" do
      before :each do
        @content_page_to_update = FactoryGirl.create(:content_page, :content_page_collection => @jobs_bucket)

        @header_content_module = FactoryGirl.create(:html_module, :title => "Old Header Module", :content => "Content for Old Header Module")
        @content_page_to_update.content_module_links.create!(:layout_container => ContentModule::HEADER, :content_module => @header_content_module)

        @main_content_module = FactoryGirl.create(:html_module, :title => "Old Main Module", :content => "Content for Old Main Module")
        @content_page_to_update.content_module_links.create!(:layout_container => ContentModule::MAIN, :content_module => @main_content_module)

        @sidebar_content_module = FactoryGirl.create(:html_module, :title => "Old Sidebar Module", :content => "Content for Old Sidebar Module")
        @content_page_to_update.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => @sidebar_content_module)

        @footer_content_module = FactoryGirl.create(:html_module, :title => "Old Footer Module", :content => "Content for Old Footer Module")
        @content_page_to_update.content_module_links.create!(:layout_container => ContentModule::FOOTER, :content_module => @footer_content_module)
      end

      it "should update header content modules" do
        put :update, :movement_id => @movement.id, :id => @content_page_to_update.id, :content_modules => {
            @header_content_module.id => { :title => "Updated Header Module", :content => "Content for Updated Header Module" }}

        content_page = ContentPage.find(@content_page_to_update.id)
        content_page.header_content_modules.first.title.should eql "Updated Header Module"
        content_page.header_content_modules.first.content.should eql "Content for Updated Header Module"
      end

      it "should update main content modules" do
        put :update, :movement_id => @movement.id, :id => @content_page_to_update.id, :content_modules => {
            @main_content_module.id => { :title => "Updated Main Module", :content => "Content for Updated Main Module" }}

        content_page = ContentPage.find(@content_page_to_update.id)
        content_page.main_content_modules.first.title.should eql "Updated Main Module"
        content_page.main_content_modules.first.content.should eql "Content for Updated Main Module"
      end

      it "should update sidebar content modules" do
        put :update, :movement_id => @movement.id, :id => @content_page_to_update.id, :content_modules => {
            @sidebar_content_module.id => { :title => "Updated Sidebar Module", :content => "Content for Updated Sidebar Module" }}

        content_page = ContentPage.find(@content_page_to_update.id)
        content_page.sidebar_content_modules.first.title.should eql "Updated Sidebar Module"
        content_page.sidebar_content_modules.first.content.should eql "Content for Updated Sidebar Module"
      end

      it "should update footer content modules" do
        put :update, :movement_id => @movement.id, :id => @content_page_to_update.id, :content_modules => {
            @footer_content_module.id => { :title => "Updated Footer Module", :content => "Content for Updated Footer Module" }}

        content_page = ContentPage.find(@content_page_to_update.id)
        content_page.footer_content_modules.first.title.should eql "Updated Footer Module"
        content_page.footer_content_modules.first.content.should eql "Content for Updated Footer Module"
      end
    end

    it "should redirect to #edit page with a notice message when updating succeeds" do
      put :update, :movement_id => @movement.id, :id => @about_page.id, :content_page => { :name => "Contact Us"}, :content_modules => {
          @about_page_content.id => { :title => "Address", :content => "Our address is..." }}

      content_page = assigns(:content_page)
      response.should redirect_to edit_admin_movement_content_page_path(@movement, content_page)
      flash[:notice].should eql "'Contact Us' has been updated."
    end

    it "should redirect to #edit page with an info message when updating fails" do
      put :update, :movement_id => @movement.id, :id => @about_page.id, :content_page => { :name => "Contact Us"}, :content_modules => {
          @about_page_content.id => { :title => "", :content => "Our address is..." }}

      content_page = assigns(:content_page)
      response.should redirect_to edit_admin_movement_content_page_path(@movement, content_page)
      flash[:info].should eql "Content module(s) not saved due to content errors."
    end
  end

  describe 'create preview' do
    before do
      @about_page_header_content = create(:accordion_module, :title => "Header", :content => "Header Content")
      @about_page_main_content = create(:html_module, :title => "Main", :content => "Main Content")
      @about_page_sidebar_content = create(:html_module, :title => "Sidebar", :content => "Sidebar Content")
      @about_page_footer_content = create(:html_module, :title => "Footer", :content => "Footer Content")
      @about_page = create(:content_page, :name => "About", :content_page_collection => @jobs_bucket)
      @about_page.content_module_links.create!(:layout_container => ContentModule::HEADER, :content_module => @about_page_header_content)
      @about_page.content_module_links.create!(:layout_container => ContentModule::MAIN, :content_module => @about_page_main_content)
      @about_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => @about_page_sidebar_content)
      @about_page.content_module_links.create!(:layout_container => ContentModule::FOOTER, :content_module => @about_page_footer_content)
    end

    it "should create duplicate action_page, content modules and autofire emails and redirect to preview" do
      page_count = ContentPage.all.count
      put :create_preview, :movement_id => @movement.id, :id => @about_page.id, :content_page => { :name => "Contact Us"}, :content_modules => {
          @about_page_header_content.id => { :title => "Updated Header", :content => "Updated Header Content" },
          @about_page_main_content.id => { :title => "Updated Main", :content => "Updated Main Content" },
          @about_page_sidebar_content.id => { :title => "Updated Sidebar", :content => "Updated Sidebar Content" },
          @about_page_footer_content.id => { :title => "Updated Footer", :content => "Updated Footer Content" }
        }

      ContentPage.unscoped.all.count.should == page_count + 1
      preview_content_page = ContentPage.unscoped.last
      @about_page.id.should_not == preview_content_page.id
      @about_page.content_page_collection.content_pages.should_not include(preview_content_page)
      @about_page.content_page_collection.should == preview_content_page.content_page_collection
      @about_page.name.should_not == "Contact Us"
      preview_content_page.name.should == "Contact Us"
      @about_page.content_modules.first.title.should == "Header"
      preview_content_page.content_modules.size == 4
      preview_content_page.header_content_modules.first.title == "Updated Header"
      preview_content_page.header_content_modules.first.content == "Updated Header Content"
      preview_content_page.main_content_modules.first.title == "Updated Main"
      preview_content_page.main_content_modules.first.content == "Updated Main Content"
      preview_content_page.sidebar_content_modules.first.title == "Updated Sidebar"
      preview_content_page.sidebar_content_modules.first.content == "Updated Sidebar Content"
      preview_content_page.footer_content_modules.first.title == "Updated Footer"
      preview_content_page.footer_content_modules.first.content == "Updated Footer Content"
      response.should be_success
      response.body.should == "/admin/movements/#{@movement.slug}/content_pages/#{preview_content_page.slug}/preview"
    end
  end

  describe 'preview' do
    before do
      @about_page_content = create(:accordion_module, :title => "Accordion")
      @about_page = create(:content_page, :name => "About", :content_page_collection => @jobs_bucket)
      @about_page.content_module_links.create!(:layout_container => ContentModule::MAIN, :content_module => @about_page_content)
    end

    it "it should prepare preview" do
      put :create_preview, :movement_id => @movement.id, :id => @about_page.id, :content_page => { :name => "Contact Us"}, :content_modules => {
          @about_page_content.id => { :title => "Address", :content => "Our address is..." }}
      preview_content_page = ContentPage.unscoped.last
      get :preview, :movement_id => @movement.id, :id => preview_content_page.id
      assigns[:content_page].id.should == preview_content_page.id
      assigns[:movement].id.should == @movement.id
      response.should render_template "preview"
      response.should render_template "_base"
    end
  end

end