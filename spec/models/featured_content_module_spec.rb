# == Schema Information
#
# Table name: featured_content_modules
#
#  id                             :integer          not null, primary key
#  featured_content_collection_id :integer
#  language_id                    :integer
#  title                          :text
#  image                          :string(255)
#  description                    :text
#  url                            :string(255)
#  button_text                    :string(255)
#  date                           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  position                       :integer
#

require 'spec_helper'

describe FeaturedContentModule do

  it 'should warn on missing title, link, and button text' do
    featured_content_module = FeaturedContentModule.new

    featured_content_module.should be_valid
    featured_content_module.should_not be_valid_with_warnings
    featured_content_module.errors.should have(1).messages[:title]
    featured_content_module.errors.should have(1).messages[:url]
    featured_content_module.errors.should have(1).messages[:button_text]
  end

  describe "populate_from_action_page" do
    before(:each) do
      @language = create(:language)
      @header_join_module = create(:join_module, language_id: @language.id, content: "Header Join Module")
      @sidebar_join_module = create(:join_module, language_id: @language.id, content: "Sidebar Join Module")
      @action_page = create(:action_page)
      create(:content_module_link, content_module: @header_join_module, page: @action_page, layout_container: ContentModule::HEADER)
      create(:content_module_link, content_module: @sidebar_join_module, page: @action_page, layout_container: ContentModule::SIDEBAR)
      @verifier = Proc.new do |featured_content_module|
        featured_content_module.populate_from_action_page(@action_page.id, @language.id)
        featured_content_module.title.should == @header_join_module.content
        featured_content_module.description.should == @sidebar_join_module.content
        featured_content_module.url.should == "/#{@language.iso_code}/actions/#{@action_page.slug}"
        featured_content_module.button_text.should == @sidebar_join_module.button_text
      end
    end

    it "should populate contents from action page" do
      @verifier.call FeaturedContentModule.new
    end

    it "should re-populate contents from action page" do
      @verifier.call FeaturedContentModule.new(title: "Title", description: "Description", url: "URL", button_text: "Button text")
    end

    it "should not populate if modules are not available" do
      action_page = create(:action_page)
      language = create(:language)
      featured_content_module = FeaturedContentModule.new
      featured_content_module.populate_from_action_page(action_page.id, language.id)
      [:title, :description, :button_text].each { |attr| featured_content_module.send(attr).should be_nil }
      featured_content_module.url.should == "/#{language.iso_code}/actions/#{action_page.slug}"
    end

  end

end
