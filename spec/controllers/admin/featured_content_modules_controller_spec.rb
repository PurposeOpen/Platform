require 'spec_helper'

describe Admin::FeaturedContentModulesController do
  before do
    admin = create(:user, :is_admin => true)
    request.env['warden'] = mock(Warden, :authenticate => admin, :authenticate! => admin)
  end

  it 'should create a new featured content module in a featured content collection' do
    movement = create(:movement, :languages => [create(:english)])
    carousel = create(:featured_content_collection, :featurable => movement.homepage)

    post :create, :movement_id => movement.id, :featured_content_collection_id => carousel.id

    FeaturedContentModule.where(:featured_content_collection_id => carousel.id).all.size.should eql 1
  end

  it 'should create a new featured content module with populated content from action page' do
    language = create(:english)
    movement = create(:movement, :languages => [language])
    carousel = create(:featured_content_collection, :featurable => movement.homepage)
    action_page = create(:action_page)

    post :create, :movement_id => movement.id, :featured_content_collection_id => carousel.id, :action_page_id => action_page.id

    FeaturedContentModule.where(:featured_content_collection_id => carousel.id).all.size.should eql 1
    featured_content_module = FeaturedContentModule.where(:featured_content_collection_id => carousel.id).first
    featured_content_module.url.should == "/#{language.iso_code}/actions/#{action_page.slug}"
  end

  it 'should destroy a featured content module' do
    featured_content_module = create(:featured_content_module)
    movement = featured_content_module.featured_content_collection.featurable.movement

    FeaturedContentModule.find(featured_content_module.id).should == featured_content_module

    put :destroy, :movement_id => movement.id, :id => featured_content_module.id

    expect {FeaturedContentModule.find(featured_content_module.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'should re-order featured content modules' do
     movement = create(:movement, :languages => [create(:english)]) 
    english = create(:language)
    portuguese = create(:language)
    collection = create(:featured_content_collection)
    module_en_0 = create(:featured_content_module, :language => english, :position => 0, :title => "EN0", :featured_content_collection => collection)
    module_en_1 = create(:featured_content_module, :language => english, :position => 1, :title => "EN1", :featured_content_collection => collection)
    module_pt_0 = create(:featured_content_module, :language => portuguese, :position => 0, :title => "PT0", :featured_content_collection => collection)
    module_pt_1 = create(:featured_content_module, :language => portuguese, :position => 1, :title => "PT1", :featured_content_collection => collection)
    module_pt_2 = create(:featured_content_module, :language => portuguese, :position => 2, :title => "PT2", :featured_content_collection => collection)

    put :sort, :featured_content_collection_id => collection.id, :movement_id=>movement.id, :id=> collection.id, :featured_content_module => {:id => module_pt_2.id, :new_position => 0}

    pt_modules = FeaturedContentModule.where(:language_id => portuguese.id, :featured_content_collection_id => collection.id).order("position")
    pt_modules[0].title.should eql "PT2"
    pt_modules[1].title.should eql "PT0"
    pt_modules[2].title.should eql "PT1"
  end
end
