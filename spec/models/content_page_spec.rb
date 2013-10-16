# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  action_sequence_id         :integer
#  name                       :string(64)
#  created_at                 :datetime
#  updated_at                 :datetime
#  deleted_at                 :datetime
#  position                   :integer
#  required_user_details      :text
#  views                      :integer          default(0), not null
#  created_by                 :string(255)
#  updated_by                 :string(255)
#  alternate_key              :integer
#  paginate_main_content      :boolean          default(FALSE)
#  no_wrapper                 :boolean
#  type                       :string(255)
#  content_page_collection_id :integer
#  movement_id                :integer
#  slug                       :string(255)
#  live_page_id               :integer
#  crowdring_campaign_name    :string(255)
#

require 'spec_helper'

describe ContentPage do

  it "should return the set of languages from the movement" do
    content_page = FactoryGirl.create(:content_page)
    english = Language.find_by_name("English")
    portuguese = FactoryGirl.create(:portuguese)
    content_page.movement.languages << portuguese

    content_page.possible_languages.should =~ [english, portuguese]
  end

  describe "converted to json format" do

    before :each do
      @english = Language.find_by_iso_code("en") || FactoryGirl.create(:english)
      @portuguese = FactoryGirl.create(:portuguese)
      movement = FactoryGirl.create(:movement, languages: [@portuguese, @english])
      collection = FactoryGirl.create(:content_page_collection, movement: movement)

      @page = FactoryGirl.create(:content_page, content_page_collection: collection, name: "Cool page")

      header_module_in_english = FactoryGirl.create(:html_module, content: "html content", language: @english)
      header_module_in_portuguese = FactoryGirl.create(:html_module, content: "conteudo html", language: @portuguese)
      FactoryGirl.create(:content_module_link, page: @page, content_module: header_module_in_english, layout_container: ContentModule::HEADER)
      FactoryGirl.create(:content_module_link, page: @page, content_module: header_module_in_portuguese, layout_container: ContentModule::HEADER)
    end

    it "should use movement's default language if no language is specified when retrieving page's content" do
      @page.movement.default_iso_code.should == "pt"
      json = @page.as_json

      json[:id].should eql @page.id
      json[:name].should eql "Cool page"
      json[:header_content_modules].first['content'].should eql "conteudo html"
      json[:main_content_modules].should eql []
      json[:sidebar_content_modules].should eql []
    end

    it "should use specified language when retrieving page's content" do
      json = @page.as_json language: "en"

      json[:id].should eql @page.id
      json[:name].should eql "Cool page"
      json[:header_content_modules].first['content'].should eql "html content"
      json[:main_content_modules].should eql []
      json[:sidebar_content_modules].should eql []
    end

    it 'should include header, main, sidebar, and footer modules' do
      main_module = FactoryGirl.create(:html_module, content: "main content", language: @english)
      FactoryGirl.create(:content_module_link, page: @page, content_module: main_module, layout_container: ContentModule::MAIN)
      sidebar_module = FactoryGirl.create(:html_module, content: "sidebar content", language: @english)
      FactoryGirl.create(:content_module_link, page: @page, content_module: sidebar_module, layout_container: ContentModule::SIDEBAR)
      footer_module = FactoryGirl.create(:html_module, content: "footer content", language: @english)
      FactoryGirl.create(:content_module_link, page: @page, content_module: footer_module, layout_container: ContentModule::FOOTER)

      json = @page.as_json language: "en"

      json[:header_content_modules].first['content'].should eql "html content"
      json[:main_content_modules].first['content'].should eql "main content"
      json[:sidebar_content_modules].first['content'].should eql "sidebar content"
      json[:footer_content_modules].first['content'].should eql "footer content"
    end

    describe 'featured content' do
      it "should include featured content modules in the resulting json" do
        featured_actions = FactoryGirl.create(:featured_content_collection, name: "Featured Actions", featurable: @page)
        en_featured_module = FactoryGirl.create(:featured_content_module, language: @english, featured_content_collection: featured_actions)
        pt_featured_module = FactoryGirl.create(:featured_content_module, language: @portuguese, featured_content_collection: featured_actions)
        carousel = FactoryGirl.create(:featured_content_collection, name: "Carousel", featurable: @page)
        en_carousel_module = FactoryGirl.create(:featured_content_module, language: @english, featured_content_collection: carousel)
        pt_carousel_module = FactoryGirl.create(:featured_content_module, language: @portuguese, featured_content_collection: carousel)

        json = @page.as_json language: "en"

        json[:id].should eql @page.id
        json[:featured_contents]['FeaturedActions'].size.should eql 1
        json[:featured_contents]['FeaturedActions'][0]['id'].should eql en_featured_module.id
        json[:featured_contents]['Carousel'].size.should eql 1
        json[:featured_contents]['Carousel'][0]['id'].should eql en_carousel_module.id
      end

      it "should sort the featured content modules by module's position" do
        carousel = FactoryGirl.create(:featured_content_collection, name: "Carousel", featurable: @page)
        carousel_module_1 = FactoryGirl.create(:featured_content_module, language: @english, featured_content_collection: carousel, position: 1)
        carousel_module_2 = FactoryGirl.create(:featured_content_module, language: @english, featured_content_collection: carousel, position: 0)

        json = @page.as_json language: "en"

        json[:id].should eql @page.id
        json[:featured_contents]['Carousel'].size.should eql 2
        json[:featured_contents]['Carousel'][0]['id'].should eql carousel_module_2.id
        json[:featured_contents]['Carousel'][1]['id'].should eql carousel_module_1.id
      end

      it "should include only valid featured content modules" do
        carousel = FactoryGirl.create(:featured_content_collection, name: "Carousel", featurable: @page)
        carousel_module_1 = FactoryGirl.create(:featured_content_module, language: @english, featured_content_collection: carousel)
        carousel_module_2 = FactoryGirl.build(:featured_content_module, language: @english, featured_content_collection: carousel, title: nil)
        carousel_module_2.save

        json = @page.as_json language: "en"

        carousel_module_2.should_not be_valid_with_warnings
        json[:id].should eql @page.id
        json[:featured_contents]['Carousel'].size.should eql 1
        json[:featured_contents]['Carousel'][0]['id'].should eql carousel_module_1.id
      end
    end
  end

  context "content page is deleted" do
    it "should delete associated featured content collections and featured content modules" do
      featured_content_collection = create(:featured_content_collection)
      content_page = featured_content_collection.featurable
      featured_content_module = create(:featured_content_module, featured_content_collection: featured_content_collection)

      content_page.destroy

      Page.where(id: content_page.id).should be_blank
      FeaturedContentCollection.where(id: featured_content_collection.id).should be_blank
      FeaturedContentModule.where(id: featured_content_module.id).should be_blank
    end
  end

end
