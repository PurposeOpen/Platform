# == Schema Information
#
# Table name: homepage_contents
#
#  id            :integer          not null, primary key
#  banner_image  :string(255)
#  banner_text   :string(255)
#  updated_at    :datetime
#  updated_by    :string(255)
#  join_headline :text
#  join_message  :text
#  follow_links  :text
#  header_navbar :text
#  footer_navbar :text
#  homepage_id   :integer
#  language_id   :integer
#

require "spec_helper"

describe HomepageContent do

  it "should serialize follow links" do
    follow_links = {"facebook" => 'facebook_url', "twitter" => 'twitter_url', "youtube" => 'youtube_url'}
    homepage_content = FactoryGirl.create(:homepage_content, follow_links: follow_links)

    homepage_content.follow_links.should == follow_links
  end

  context "saved with follow links set to nil," do

    it "should set follow links to an empty hash" do
      english = FactoryGirl.create(:english)
      homepage_content = HomepageContent.new(follow_links: nil, language: english)
      homepage_content.save!

      homepage_content.follow_links.should == {}
    end

  end

  it "should return a collection of homepage_contents for each language and build one if it doesn't exist for the language" do
    english = FactoryGirl.create(:english)
    spanish = FactoryGirl.create(:spanish)
    portuguese = FactoryGirl.create(:portuguese)
    movement = FactoryGirl.create(:movement, languages: [english, spanish, portuguese])
    homepage = movement.homepage
    homepage_content_en = FactoryGirl.create(:homepage_content, homepage: homepage, language: english)

    homepage.build_content_for_all_languages.map { |c| c.language }.should match_array([english, spanish, portuguese])
  end

  describe "Logically validate completeness of content" do

    it "return false if content is not complete" do
      language = create(:language)
      movement = create(:movement, languages: [language])
      homepage = movement.homepage
      homepage_content_lng = create(:homepage_content, homepage: homepage, language: language, banner_image: "banner_image")
      homepage_content_lng.content_complete?.should be_false
    end

    it "return true if content is complete" do
      language = create(:language)
      movement = create(:movement, languages: [language])
      homepage = movement.homepage
      homepage_content_lng = create(:homepage_content, homepage: homepage, language: language, banner_image: "banner_image", banner_text: "banner text", join_headline: "Join", join_message: "Join", follow_links: {sample: "http://test.com"}, header_navbar: "header", footer_navbar: "footer")
      homepage_content_lng.content_complete?.should be_true
    end
  end
end
