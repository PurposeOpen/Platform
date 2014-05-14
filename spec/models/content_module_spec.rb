# encoding: utf-8
# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

require "spec_helper"

describe ContentModule do
  describe "serialization/deserialization" do

    class FooModule < ContentModule
      option_fields :harry
    end

    class MultipleFieldDeclarationsModule < ContentModule
      option_fields :the_first
      option_fields :the_second, :the_third
    end

    it "creates option attributes" do
      dummy = FactoryGirl.create(:dummy_module)
      lambda { dummy.foo = "value" }.should_not raise_error
      lambda { dummy.xxx = "value" }.should raise_error
    end

    it "saves and reloads serializable fields" do
      dm = FactoryGirl.create(:dummy_module, foo: 'foo_value', bar: 'bar_value')
      dm.foo.should eql('foo_value')
      dm.bar.should eql('bar_value')

      dm.reload

      dm.foo.should eql('foo_value')
      dm.bar.should eql('bar_value')
    end

    it "creates attributes only for the appropriate subclass" do
      foo = FactoryGirl.build(:dummy_module)
      lambda { foo.foo = "sally" }.should_not raise_error
      lambda { foo.nonsense = "bar" }.should raise_error
    end

    it "handles attributes sensibly without saving" do
      dm = DummyModule.new
      dm.foo = "bar"
      dm.save!(validate: false)
      dm.reload
      dm.foo.should == "bar"
    end

    it "allows multiple calls to option_fields" do
      mfdm = MultipleFieldDeclarationsModule.new(the_first: 1, the_second: 2, the_third: 3, language: FactoryGirl.create(:language))
      mfdm.save!
      mfdm = ContentModule.find(mfdm.id)
      mfdm.the_first.should == 1
      mfdm.the_second.should == 2
      mfdm.the_third.should == 3
    end
  end

  describe "public activity stream HTML" do
    before(:each) do
      @page = FactoryGirl.create(:action_page)
      @movement = @page.action_sequence.campaign.movement
    end

    it "substitutes $NAME for user first name" do
      dm = FactoryGirl.create(:dummy_module, public_activity_stream_template: "{NAME|Someone} is AWESOME", language: @page.movement.default_language)
      @page.content_modules << dm
      user = FactoryGirl.create(:user, first_name: "rick")
      dm.public_activity_stream_html(user, @page).should == "<span class=\"name\">Rick</span> is AWESOME"
      user.first_name = nil
      dm.public_activity_stream_html(user, @page).should == "<span class=\"name\">Someone</span> is AWESOME"
    end

    context 'substitute $HEADER' do
      let(:language_for_module) {create(:language)}
      let(:dm) {create(:dummy_module, public_activity_stream_template: "My content is {HEADER|}", language: language_for_module, content: "I am the Header")}
      let(:dm2) {create(:dummy_module, public_activity_stream_template: "My content is {HEADER|}", language: @page.movement.default_language, content: "I am the Header in the default language")}
      let(:dm3) {create(:dummy_module, public_activity_stream_template: "My content is {HEADER|}", language: @page.movement.default_language, content: "I am the Header in the default language")}
      let(:user) {create(:user, country_iso: "fr")}


      before(:each) do
        @page.content_modules << dm
        create(:header_module_link, page: @page, content_module: dm )
        create(:header_module_link, page: @page, content_module: dm2 )
        @link = create(:content_module_link, page: create(:action_page), content_module: dm3)

      end
      it "substitutes HEADER in the language specified" do
        dm.public_activity_stream_html(user, @page, language_for_module).should == "My content is I am the Header"
      end

      it "substitutes HEADER in the movement's language if no language is specified" do
        dm.public_activity_stream_html(user, @page, nil).should == "My content is I am the Header in the default language"
      end

      it "substitutes empty if there are no header contents_modules to substitute" do
        dm.public_activity_stream_html(user, @link.page, create(:language)).should == "My content is "
        dm3.public_activity_stream_html(user, @link.page, nil).should == "My content is "
        dm3.public_activity_stream_html(user, @link.page, language_for_module).should == "My content is "
      end
    end

    context 'substitute $COUNTRY' do
      let(:dm) {create(:dummy_module, public_activity_stream_template: "I'm {(from )COUNTRY|lost}", language: @page.movement.default_language)}
      let(:user) {create(:user, country_iso: "fr")}

      before(:each) do
        @page.content_modules << dm
      end

      it "substitutes $COUNTRY for user's country in english by default" do
        dm.public_activity_stream_html(user, @page).should == "I'm from France"
        user.country_iso = nil
        dm.public_activity_stream_html(user, @page).should == "I'm lost"
      end

      it "substitutes $COUNTRY for user's country in local language" do
        portuguese = create(:portuguese)
        dm.public_activity_stream_html(user, @page, portuguese).should == "I'm from França"
        user.country_iso = nil
        dm.public_activity_stream_html(user, @page).should == "I'm lost"
      end
    end

    it "links [linked text] to the first page in the sequence" do
      first_page = FactoryGirl.create(:action_page)
      @page.action_sequence.action_pages.unshift(first_page)

      dm = FactoryGirl.create(:dummy_module, public_activity_stream_template: "This is a [link]", language: @movement.default_language)
      @page.content_modules << dm
      href = Rails.application.routes.url_helpers.page_path(@page.action_sequence.campaign.friendly_id, @page.action_sequence.friendly_id, first_page.friendly_id)

      dm.public_activity_stream_html(FactoryGirl.create(:user), @page).should ==
        %{This is a <a data-action-name="#{@page.action_sequence.friendly_id}" data-page-name="#{first_page.friendly_id}">link</a>}
    end

    it "returns nil if the content module is not an ask module" do
      normal_module = Class.new(ContentModule)
      dm = normal_module.new(public_activity_stream_template: "Foo Bar")
      dm.public_activity_stream_html(nil, nil).should be_nil
    end

    it "renders the content module text in the appropriate language, using the template provided by that language's module" do
      page, user = FactoryGirl.create(:action_page), FactoryGirl.create(:user)
      l1, l2 = FactoryGirl.create(:language), FactoryGirl.create(:language)

      m1 = FactoryGirl.build(:dummy_module, public_activity_stream_template: "First language", language: l1)
      m2 = FactoryGirl.build(:dummy_module, public_activity_stream_template: "Second language", language: l2)

      page.content_modules << m1
      page.content_modules << m2

      m1.public_activity_stream_html(user, page, l2).should == "Second language"
    end
  end

  describe "linking to multiple pages" do
    it "knows if it is linked" do
      dm = FactoryGirl.create(:dummy_module)
      dm.should_not be_linked

      ContentModuleLink.create!(content_module: dm, page: FactoryGirl.create(:action_page))
      dm.reload
      dm.should_not be_linked

      ContentModuleLink.create!(content_module: dm, page: FactoryGirl.create(:action_page))
      dm.reload
      dm.should be_linked
    end
  end

  describe "first image" do
    it "returns the uri to first image in the module" do
      dm = FactoryGirl.create(:dummy_module, content: '<h2>Hello</h2><div><br>something<div><img src="/images/some_header_image.png"/></div></div><table><tr><td></td></tr></table>')
      dm.first_image.should == "/images/some_header_image.png"
    end

    it "returns false if there is no first image" do
      dm = FactoryGirl.create(:dummy_module, content: '<h2>Hello</h2><div><br>something<div>no image</div></div><table><tr><td></td></tr></table>')
      dm.first_image.should == false
    end

  end

  describe "sanitizing user-entered HTML" do
    it "tidies content" do
      dm = FactoryGirl.create(:dummy_module, content: "<div class=> Content")
      dm.content.should == "<div class=\"\"> Content</div>"
    end
  end

  describe "as_json" do
    it "should include type in json" do
      petition = PetitionModule.create(content: "Some content", title: "Petition title")
      taf = TellAFriendModule.create(content: "Some content", title: "Petition title")
      petition_json = JSON.parse(petition.to_json)
      taf_json = JSON.parse(taf.to_json)

      petition_json["type"].should eql "PetitionModule"
      taf_json["type"].should eql "TellAFriendModule"
    end

    it "should run its render its content as Markdown if flagged" do
      HtmlModule.new(content: "This is some text", use_markdown: true).as_json[:content].should == "<p>This is some text</p>\n"
    end
  end

  describe "has errors or warnings" do
    it "should check for errors and warnings, and generate messages for both" do
      mod = PetitionModule.new
      mod.should_not be_valid_with_warnings

      mod.errors[:language_id].should_not be_empty
      mod.errors[:signatures_goal].should_not be_empty
    end
  end
end
