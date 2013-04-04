require 'spec_helper'

describe Admin::ContentModulesController do

  before do
    admin = FactoryGirl.create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => admin, :authenticate! => admin)
  end

  describe "#create" do

    context "content page" do
      before(:each) do
        @movement = FactoryGirl.create(:movement)
        @movement.default_language = @movement.languages.first
        @movement.movement_locales.create!(:language => FactoryGirl.create(:portuguese), :default => false)

        @footer_bucket = FactoryGirl.create(:content_page_collection, :name => 'Footer', :movement => @movement)
        @jobs_bucket = FactoryGirl.create(:content_page_collection, :name => 'Jobs', :movement => @movement)
        @movement.content_page_collections = [ @footer_bucket, @jobs_bucket ]

        @about_page = FactoryGirl.create(:content_page, :content_page_collection => @footer_bucket)
      end

      it "should create an HTML module for all languages in a ContentPage" do
        post :create, :movement_id => @about_page.movement.id, :page_id => @about_page.id, :page_type => ContentPage.to_s, :type => HtmlModule.to_s, :container => ContentModule::MAIN.to_s

        page = ContentPage.find(@about_page.id)
        page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:english)).size.should eql 1
        page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:portuguese)).size.should eql 1
        page.content_modules[0].should be_an_instance_of HtmlModule
        page.content_modules[1].should be_an_instance_of HtmlModule

        response.should render_template :partial => "admin/content_modules/_content_modules"
      end

      it "should create an Accordion module for all languages in a ContentPage" do
        post :create, :movement_id => @about_page.movement.id, :page_id => @about_page.id, :page_type => ContentPage.to_s, :type => AccordionModule.to_s, :container => ContentModule::MAIN.to_s

        page = ContentPage.find(@about_page.id)
        page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:english)).size.should eql 1
        page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:portuguese)).size.should eql 1
        page.content_modules[0].should be_an_instance_of AccordionModule
        page.content_modules[1].should be_an_instance_of AccordionModule
      end

    end

    context "page" do
      it "should create an Petition module for all languages in a Page" do
        @petition_page = FactoryGirl.create(:action_page)

        post :create, :movement_id => @petition_page.movement.id, :page_id => @petition_page.id, :page_type => ActionPage.to_s, :type => PetitionModule.to_s, :container => ContentModule::MAIN.to_s

        page = ActionPage.find(@petition_page.id)
        page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:english)).size.should eql 1
        page.content_modules[0].should be_an_instance_of PetitionModule
      end

      it "should create modules for a page when the page friendly id is specified instead of its numeric id" do
        @petition_page = FactoryGirl.create(:action_page)

        post :create, :movement_id => @petition_page.movement.id, :page_id => @petition_page.friendly_id, :page_type => ActionPage.to_s, :type => PetitionModule.to_s, :container => ContentModule::MAIN.to_s

        page = ActionPage.find(@petition_page.id)
        page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:english)).size.should eql 1
        page.content_modules[0].should be_an_instance_of PetitionModule
      end
    end
  end

  describe "#delete" do
    it "should remove the link between a page and a content module" do
      petition_page = FactoryGirl.create(:action_page)
      taf_page = FactoryGirl.create(:action_page)
      html_module = FactoryGirl.create(:html_module)

      petition_html_module_link = FactoryGirl.create(:content_module_link, :page => petition_page, :content_module => html_module)
      taf_html_module_link = FactoryGirl.create(:content_module_link, :page => taf_page, :content_module => html_module)

      delete :delete, :movement_id => taf_page.movement.id, :page_id => taf_page.id, :content_module_id=>html_module.id, :id => html_module.id
      taf_page.reload.content_modules.should be_empty
      petition_page.reload.content_modules.size.should == 1
    end

    it "should remove the link between a page and a content module when the page is specified by its friendly id" do
      petition_page = FactoryGirl.create(:action_page)
      taf_page = FactoryGirl.create(:action_page)
      html_module = FactoryGirl.create(:html_module)

      petition_html_module_link = FactoryGirl.create(:content_module_link, :page => petition_page, :content_module => html_module)
      taf_html_module_link = FactoryGirl.create(:content_module_link, :page => taf_page, :content_module => html_module)

      delete :delete, :movement_id => taf_page.movement.id, :page_id => taf_page.friendly_id, :id => html_module.id, :content_module_id=>html_module.id
      taf_page.reload.content_modules.should be_empty
      petition_page.reload.content_modules.size.should == 1
    end
  end

  describe "#create_links_to_existing_modules" do
    it "should link all of the source page container's content modules to the target page's container" do
      source_page = FactoryGirl.create(:action_page)
      target_page = FactoryGirl.create(:action_page)

      post :create_links_to_existing_modules, :movement_id => source_page.movement.id, :page_type => source_page.class.to_s, :page_id => source_page.id, :target_page_type => target_page.class.to_s, :target_page_id => target_page.id, :container => ContentModule::MAIN, :id => source_page.id

      target_page.reload.content_modules.should eq source_page.content_modules
    end

    it "should render the newly linked content modules partials" do
      petition_page = FactoryGirl.create(:action_page)
      image_html_module = FactoryGirl.create(:html_module)
      text_html_module = FactoryGirl.create(:html_module)
      petition_image_html_module_link = FactoryGirl.create(:header_module_link, :page => petition_page, :content_module => image_html_module)
      petition_text_html_module_link = FactoryGirl.create(:header_module_link, :page => petition_page, :content_module => text_html_module)

      taf_page = FactoryGirl.create(:action_page)
      post :create_links_to_existing_modules, :movement_id => petition_page.movement.id, :page_type => petition_page.class.to_s, :page_id => petition_page.id, :target_page_type => taf_page.class.to_s, :target_page_id => taf_page.id, :container => ContentModule::MAIN, :id => taf_page.id


      response.should render_template :partial => "admin/content_modules/_content_modules"
    end
  end

  describe "#sort" do
    it "should set the position of each of the modules after ordering" do
      page = FactoryGirl.create(:action_page)
      m1 = FactoryGirl.create(:content_module_link, :page => page, :position => 0, :layout_container => ContentModule::MAIN)
      m2 = FactoryGirl.create(:content_module_link, :page => page, :position => 1, :layout_container => ContentModule::MAIN)

      put :sort, :movement_id => page.movement.id, :page_id => page.id, :page_type => ActionPage.to_s,  :id => page.id, :content_module => {
          :content_module_id => m1.content_module.id,
          :new_container => m1.layout_container,
          :new_position => 1
      }

      m1.reload.position.should == 1
      m2.reload.position.should == 0
    end
  end

  context "two movements have pages with the same name" do
    before do
      @allout = FactoryGirl.create(:movement, :name => "All Out")
      @allout_campaign = FactoryGirl.create(:campaign, :movement => @allout)
      @allout_action_sequence = FactoryGirl.create(:action_sequence, :campaign => @allout_campaign)
      @allout_page = FactoryGirl.create(:action_page, :name => "Join", :action_sequence => @allout_action_sequence)

      @walkfree = FactoryGirl.create(:movement, :name => "Walk Free")
      @walkfree_campaign = FactoryGirl.create(:campaign, :movement => @walkfree)
      @walkfree_action_sequence = FactoryGirl.create(:action_sequence, :campaign => @walkfree_campaign)
      @walkfree_page = FactoryGirl.create(:action_page, :name => "Join", :action_sequence => @walkfree_action_sequence)
    end

    it "should create modules on All Out's page" do
      post :create, :movement_id => @allout.friendly_id, :page_id => @allout_page.friendly_id, :page_type => ActionPage.to_s, :type => PetitionModule.to_s, :container => ContentModule::MAIN.to_s

      page = ActionPage.find(@allout_page.id)
      page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:english)).size.should eql 1
      page.content_modules[0].should be_an_instance_of PetitionModule
    end

    it "should create modules on Walk Free's page" do
      post :create, :movement_id => @walkfree.friendly_id, :page_id => @walkfree_page.friendly_id, :page_type => ActionPage.to_s, :type => PetitionModule.to_s, :container => ContentModule::MAIN.to_s

      page = ActionPage.find(@walkfree_page.id)
      page.modules_for_container_and_language(ContentModule::MAIN, FactoryGirl.create(:english)).size.should eql 1
      page.content_modules[0].should be_an_instance_of PetitionModule
    end

    it "should delete modules from All Out's page" do
      allout_module = FactoryGirl.create(:html_module, :pages => [@allout_page])
      walkfree_module = FactoryGirl.create(:html_module, :pages => [@walkfree_page])

      delete :delete, :movement_id => @allout.id, :page_id => @allout_page.friendly_id, :id => allout_module.id, :content_module_id=>allout_module.id

      ActionPage.find(@allout_page.id).content_modules.size.should eql 0
      ActionPage.find(@walkfree_page.id).content_modules.size.should eql 1
    end

    it "should delete modules from WalkFree's page" do
      allout_module = FactoryGirl.create(:html_module, :pages => [@allout_page])
      walkfree_module = FactoryGirl.create(:html_module, :pages => [@walkfree_page])

      delete :delete, :movement_id => @walkfree.id, :page_id => @walkfree_page.friendly_id, :id => walkfree_module.id, :content_module_id=>walkfree_module.id

      ActionPage.find(@walkfree_page.id).content_modules.size.should eql 0
      ActionPage.find(@allout_page.id).content_modules.size.should eql 1
    end
  end
end