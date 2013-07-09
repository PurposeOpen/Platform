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

require "spec_helper"

describe Page do

  describe 'validations' do
    before do
      @action_page = create(:action_page, :name => 'Duplicate')
      @movement = @action_page.movement
    end

    it 'should validate uniqueness of name within movement' do
      content_page_collection = create(:content_page_collection, :movement => @movement)
      content_page = build(:content_page, :name => 'Duplicate', :content_page_collection => content_page_collection)
      content_page.should_not be_valid
      content_page.errors.messages[:name].should == ["must be unique within movement."]
      @action_page.should be_valid
    end

    it 'should ensure unique slug while updating' do
      content_page_collection = create(:content_page_collection, :movement => @movement)
      content_page = create(:content_page, :name => 'Some Name', :content_page_collection => content_page_collection)
      @action_page.update_attributes(:name => 'Some Name')
      @action_page.errors.messages[:name].should == ["must be unique within movement."]
    end
  end

  describe 'as_json' do
    it 'should give options for generating json' do
      action_page = create(:action_page)
      json_options = action_page.as_json
      json_options[:id].should == action_page.id
      json_options[:name].should == action_page.name
      json_options[:type].should == action_page.type
    end
  end

  describe 'register_click_from' do
    before do
      @page = create(:action_page)
      @email = create(:email)
      @user = create(:user)
    end

    context 'email or user are nil' do
      it 'should not create a click event' do
        @page.register_click_from(@email, nil)
        @page.register_click_from(nil, @user)
        PushClickedEmail.count.should == 0
      end
    end

    context 'click was already registered' do
      it 'should create another click event' do
        PushClickedEmail.create(:movement_id => @email.movement.id, :push_id => @email.blast.push.id, :email_id => @email.id, :user_id => @user.id)
        @page.register_click_from(@email, @user)

        PushClickedEmail.count.should == 2
      end
    end

    describe 'default scope' do
      it "should return action pages with live_page_id = nil by default" do
        as = create(:action_sequence)
        ap1 = create(:action_page, :live_page_id => nil, :action_sequence => as)
        ap2 = create(:action_page, :live_page_id => ap1.id, :action_sequence => as)
        as.action_pages.should include ap1
        as.action_pages.should_not include ap2
      end

      it "should return content pages with live_page_id = nil by default" do
        movement = create(:movement)
        content_page_collection = create(:content_page_collection, :movement => movement)
        cp1 = create(:content_page, :live_page_id => nil, :content_page_collection => content_page_collection, :name => 'name1')
        cp2 = create(:content_page, :live_page_id => cp1.id, :content_page_collection => content_page_collection, :name => 'name2')
        movement.content_page_collections.first.content_pages.should include cp1
        movement.content_page_collections.first.content_pages.should_not include cp2
      end
    end

    describe "for_preview scope" do
      it "should only include conditions deleted_at is nil and movement when called with unscoped" do
        movement = create(:movement)
        Page.unscoped.for_preview(movement.id).to_sql.should == Page.unscoped.where(:deleted_at => nil, :movement_id => movement.id).to_sql
      end
    end

    it 'should register a click (and create an email viewed event)' do
      @page.register_click_from(@email, @user)

      PushClickedEmail.count.should == 1
      PushViewedEmail.count.should == 1
    end
  end

  describe "content_modules" do
    before(:each) do
      @language = create(:language)
      @header_join_module = create(:join_module, language_id: @language.id, content: "Content 1")
      @sidebar_join_module = create(:join_module, language_id: @language.id, content: "Content 2")
      @footer_content_module = create(:html_module)
      @main_content_module = create(:html_module)
      @action_page = create(:action_page)
      create(:content_module_link, content_module: @header_join_module, page: @action_page, layout_container: ContentModule::HEADER)
      create(:content_module_link, content_module: @sidebar_join_module, page: @action_page, layout_container: ContentModule::SIDEBAR)
      create(:content_module_link, content_module: @footer_content_module, page: @action_page, layout_container: ContentModule::FOOTER)
      create(:content_module_link, content_module: @main_content_module, page: @action_page, layout_container: ContentModule::MAIN)
    end

    describe "content_modules_for_language" do
      it "should return header content modules for a language" do
        @action_page.header_content_modules_for_language(@language.id).should == [@header_join_module]
        @action_page.header_content_modules_for_language(create(:language).id).should be_empty
      end

      it "should return sidebar content modules for a language" do
        @action_page.sidebar_content_modules_for_language(@language.id).should == [@sidebar_join_module]
        @action_page.sidebar_content_modules_for_language(create(:language).id).should be_empty
      end

      it "should return all content modules of a given type and language" do
        @action_page.modules_for_container_and_language(ContentModule::HEADER, @language).should == [@header_join_module]
      end
    end

    it "should return content modules" do
      @action_page.header_content_modules.should == [@header_join_module]
      @action_page.sidebar_content_modules.should == [@sidebar_join_module]
      @action_page.main_content_modules.should == [@main_content_module]
      @action_page.footer_content_modules.should == [@footer_content_module]
    end
  end
end
