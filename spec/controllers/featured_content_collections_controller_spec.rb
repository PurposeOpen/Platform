require 'spec_helper'

describe Admin::FeaturedContentCollectionsController do

  before do
    admin = FactoryGirl.create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => admin, :authenticate! => admin)
  end

  describe 'update' do
    it 'should update featured content modules' do
      english = FactoryGirl.create(:english)
      homepage_content = FactoryGirl.create(:homepage_content, :language => english)
      homepage = homepage_content.homepage
      movement = homepage.movement

      hp_collection = FactoryGirl.create(:featured_content_collection, :featurable => homepage, :name => 'Carousel')

      carousel_module_1 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english)
      carousel_module_2 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english)

      put :update, :movement_id => movement.id, :id => hp_collection.id, :featured_content_modules => {carousel_module_1.id => {:title => 'HI!!!!',
          :description => "I'm excited!!!!", :url => 'url', :image => 'image_url', :button_text => 'button text', :date => 'string date'}}

      modified_module = FeaturedContentModule.find(carousel_module_1.id)
      modified_module.title.should == 'HI!!!!'
      modified_module.description.should == "I'm excited!!!!"
      modified_module.image.should == 'image_url'
      modified_module.url.should == 'url'
      modified_module.button_text.should == 'button text'
      modified_module.date.should == 'string date'
    end
  end

  describe 'edit' do
    it 'should set up the featured content collection to be edited' do
      english = FactoryGirl.create(:english)
      homepage_content = FactoryGirl.create(:homepage_content, :language => english)
      homepage = homepage_content.homepage
      movement = homepage.movement

      hp_collection = FactoryGirl.create(:featured_content_collection, :featurable => homepage, :name => 'Carousel')

      carousel_module_1 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english)
      carousel_module_2 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english)

      get :edit, :movement_id => movement.id, :id => hp_collection.id

      assigns[:featured_content_collection].should == hp_collection
    end

    it 'should pull up the featured content modules sorted by position' do
      english = FactoryGirl.create(:language)
      homepage_content = FactoryGirl.create(:homepage_content, :language => english)
      homepage = homepage_content.homepage
      movement = homepage.movement

      hp_collection = FactoryGirl.create(:featured_content_collection, :featurable => homepage, :name => 'Carousel')

      carousel_module_1 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english, :position => 2)
      carousel_module_2 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english, :position => 0)
      carousel_module_3 = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english, :position => 1)

      get :edit, :movement_id => movement.id, :id => hp_collection.id

      assigns[:featured_content_collection].should == hp_collection
      assigns[:featured_content_collection].featured_content_modules[0].should == carousel_module_2
      assigns[:featured_content_collection].featured_content_modules[1].should == carousel_module_3
      assigns[:featured_content_collection].featured_content_modules[2].should == carousel_module_1
    end
  end

	describe 'index' do
		it 'should set up featured content collections organized by type' do
			english = FactoryGirl.create(:english)
			homepage_content = FactoryGirl.create(:homepage_content, :language => english)
      homepage = homepage_content.homepage
      movement = homepage.movement

			content_page_collection = FactoryGirl.create(:content_page_collection, :name => 'Static Pages', :movement => movement)
			content_page = FactoryGirl.create(:content_page, :name => 'About', :content_page_collection => content_page_collection)

      hp_collection = FactoryGirl.create(:featured_content_collection, :featurable => homepage, :name => 'Carousel')

			hp_module = FactoryGirl.create(:featured_content_module, :featured_content_collection => hp_collection,
          :language => english)

			ap_collection = FactoryGirl.create(:featured_content_collection, :featurable => content_page,
          :name => 'Press Releases')

			ap_module = FactoryGirl.create(:featured_content_module, :featured_content_collection => ap_collection, 
          :language => english)

			get :index, :movement_id => movement.id

			assigns[:featured_pages].should == {
        homepage => [hp_collection],
        content_page => [ap_collection]
      }
		end

    it 'should set up featured content collections organized by type when there are multiple content pages with featured contents' do
      english = FactoryGirl.create(:english)
      homepage_content = FactoryGirl.create(:homepage_content, :language => english)
      movement = homepage_content.homepage.movement

      content_page_collection = FactoryGirl.create(:content_page_collection, :name => 'Static Pages', :movement => movement)
      content_page_1 = FactoryGirl.create(:content_page, :name => 'About', :content_page_collection => content_page_collection)
      content_page_2 = FactoryGirl.create(:content_page, :name => 'Help', :content_page_collection => content_page_collection)

      ap_collection_1 = FactoryGirl.create(:featured_content_collection, :featurable => content_page_1,
          :name => 'Press Releases')
      ap_module_1 = FactoryGirl.create(:featured_content_module, :featured_content_collection => ap_collection_1, 
          :language => english)

      ap_collection_2 = FactoryGirl.create(:featured_content_collection, :featurable => content_page_2,
          :name => 'Press Releases')
      ap_module_2 = FactoryGirl.create(:featured_content_module, :featured_content_collection => ap_collection_2, 
          :language => english)

      get :index, :movement_id => movement.id

      assigns[:featured_pages].should == {
        content_page_1 => [ap_collection_1],
        content_page_2 => [ap_collection_2]
      }
    end
	end
    it 'should set up featured content collections organized by type when a page has multiple featured content collections' do
      english = FactoryGirl.create(:english)
      homepage_content = FactoryGirl.create(:homepage_content, :language => english)
      homepage = homepage_content.homepage
      movement = homepage.movement

      carousel = FactoryGirl.create(:featured_content_collection, :featurable => homepage, :name => 'Carousel')
      featured = FactoryGirl.create(:featured_content_collection, :featurable => homepage, :name => 'Featured')

      carousel_module = FactoryGirl.create(:featured_content_module, :featured_content_collection => carousel,
          :language => english)
      featured_module = FactoryGirl.create(:featured_content_module, :featured_content_collection => featured,
          :language => english)

      get :index, :movement_id => movement.id

      assigns[:featured_pages].should == {
        homepage => [carousel, featured]
      }
    end

end
