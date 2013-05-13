#encoding: utf-8
require "spec_helper"

describe Api::ContentPagesController do
  
  it "should return a content page's content in json format, and create a user activity event for the click" do
    header_content = FactoryGirl.create(:accordion_module, :title => "Header", :content => "Welcome!")
    sidebar_content = FactoryGirl.create(:html_module, :content => "Look to the left")
    main_content = FactoryGirl.create(:html_module, :content => "Look up")
    page = FactoryGirl.create(:content_page, :name => "Static page")
    FactoryGirl.create(:header_module_link, :content_module => header_content, :page => page)
    FactoryGirl.create(:sidebar_module_link, :content_module => sidebar_content, :page => page)
    FactoryGirl.create(:main_module_link, :content_module => main_content, :page => page)

    user = FactoryGirl.create(:user, :movement => page.movement)
    email = FactoryGirl.create(:email)

    tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

    get :show, :locale => :en, :movement_id => page.movement.id, :id => page.id, :t => tracking_hash

    data = ActiveSupport::JSON.decode(response.body)
    data["id"].should eql page.id
    data["name"].should eql "Static page"
    data["header_content_modules"].first["title"].should eql "Header"
    data["header_content_modules"].first["content"].should eql "Welcome!"
    data["sidebar_content_modules"].first["content"].should eql "Look to the left"
    data["main_content_modules"].first["content"].should eql "Look up"
    response.headers['Content-Language'].should eql "en"
  end

  it "should return a content page' featured content modules sorted by their position" do
    page = FactoryGirl.create(:content_page, :name => "Static page")
    featured_actions = FactoryGirl.create(:featured_content_collection, :name => 'Featured Actions', :featurable => page)
    page.featured_content_collections << featured_actions
    page.save!
    third_module = FactoryGirl.create(:featured_content_module, :position => 2, :title => "Third", :featured_content_collection => featured_actions)
    first_module = FactoryGirl.create(:featured_content_module, :position => 0, :title => "First", :featured_content_collection => featured_actions)
    second_module = FactoryGirl.create(:featured_content_module, :position => 1, :title => "Second", :featured_content_collection => featured_actions)
    featured_actions.featured_content_modules << third_module
    featured_actions.featured_content_modules << first_module
    featured_actions.featured_content_modules << second_module
    featured_actions.save!
    
    get :show, :locale => :en, :movement_id => page.movement.id, :id => page.id

    data = ActiveSupport::JSON.decode(response.body)
        data["featured_contents"]["FeaturedActions"][0]["title"].should eql "First"
    data["featured_contents"]["FeaturedActions"][1]["title"].should eql "Second"
    data["featured_contents"]["FeaturedActions"][2]["title"].should eql "Third"
    response.headers['Content-Language'].should eql "en"
  end

  it "should return 404 when page is not found" do
    get :show, :locale => :en, :movement_id => FactoryGirl.create(:movement).id, :id => 69

    response.response_code.should eql 404
  end

  it "should return content page for preview" do
    page = FactoryGirl.create(:content_page, :name => "Static page")
    featured_actions = FactoryGirl.create(:featured_content_collection, :name => 'Featured Actions', :featurable => page)
    page.featured_content_collections << featured_actions
    page.save!
    third_module = FactoryGirl.create(:featured_content_module, :position => 2, :title => "Third", :featured_content_collection => featured_actions)
    first_module = FactoryGirl.create(:featured_content_module, :position => 0, :title => "First", :featured_content_collection => featured_actions)
    second_module = FactoryGirl.create(:featured_content_module, :position => 1, :title => "Second", :featured_content_collection => featured_actions)
    featured_actions.featured_content_modules << third_module
    featured_actions.featured_content_modules << first_module
    featured_actions.featured_content_modules << second_module
    featured_actions.save!
    get :preview, :locale => :en, :movement_id => page.movement.id, :id => page.id

    data = ActiveSupport::JSON.decode(response.body)
    data["featured_contents"]["FeaturedActions"][0]["title"].should eql "First"
    data["featured_contents"]["FeaturedActions"][1]["title"].should eql "Second"
    data["featured_contents"]["FeaturedActions"][2]["title"].should eql "Third"
    response.headers['Content-Language'].should eql "en"
  end

  it "should return content page for preview for an preview page - one that has live page id set" do
    parent_page = create(:content_page, :name => "Parent Page", :live_page_id => nil)
    page = FactoryGirl.create(:content_page, :name => "Static page", :live_page_id => parent_page.id)
    featured_actions = FactoryGirl.create(:featured_content_collection, :name => 'Featured Actions', :featurable => page)
    page.featured_content_collections << featured_actions
    page.save!
    third_module = FactoryGirl.create(:featured_content_module, :position => 2, :title => "Third", :featured_content_collection => featured_actions)
    first_module = FactoryGirl.create(:featured_content_module, :position => 0, :title => "First", :featured_content_collection => featured_actions)
    second_module = FactoryGirl.create(:featured_content_module, :position => 1, :title => "Second", :featured_content_collection => featured_actions)
    featured_actions.featured_content_modules << third_module
    featured_actions.featured_content_modules << first_module
    featured_actions.featured_content_modules << second_module
    featured_actions.save!
    get :preview, :locale => :en, :movement_id => page.movement.id, :id => page.id

    data = ActiveSupport::JSON.decode(response.body)
    data["featured_contents"]["FeaturedActions"][0]["title"].should eql "First"
    data["featured_contents"]["FeaturedActions"][1]["title"].should eql "Second"
    data["featured_contents"]["FeaturedActions"][2]["title"].should eql "Third"
    response.headers['Content-Language'].should eql "en"
  end
end