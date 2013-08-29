require "spec_helper"

describe Admin::ActionPagesController do
  include Devise::TestHelpers # to give your spec access to helpers

  before(:each) do
    @language1 = FactoryGirl.create(:language)
    @language2 = FactoryGirl.create(:language)
    @language3 = FactoryGirl.create(:language)

    @movement = FactoryGirl.create(:movement, :languages => [@language1, @language2, @language3])
    @campaign = FactoryGirl.create(:campaign, :movement => @movement)
    @action_sequence = FactoryGirl.create(:action_sequence, :campaign => @campaign)
    @action_page = FactoryGirl.create(:action_page, :action_sequence => @action_sequence)

    # mock up an authentication in the underlying warden library
    request.env['warden'] = mock(Warden, :authenticate => FactoryGirl.create(:user, :is_admin => true),
                                 :authenticate! => FactoryGirl.create(:user, :is_admin => true))
  end

  describe "update" do
    it "with content modules" do
      footer_content_module = create(:html_module, :content => "old content")
      create(:content_module_link, content_module: footer_content_module, page: @action_page, layout_container: ContentModule::FOOTER)
      put :update, :id => @action_page.id,
        :movement_id => @movement.id,
        :action_sequence_id => @action_sequence.id,
        :content_modules => {"#{footer_content_module.id}" => {:content => "new content"}}
      footer_content_module.reload.content.should == "new content"
      response.should render_template "edit"
    end

    context "one or more content modules are invalid" do
      it "should go back to the edit page with an appropriate message" do
        content_module = FactoryGirl.create(:accordion_module)
        FactoryGirl.create(:content_module_link, :page => @action_page, :content_module => content_module)

        put :update, :id => @action_page.id,
                     :movement_id => @movement.id,
                     :action_sequence_id => @action_sequence.id,
                     :content_modules => {"#{content_module.id}" => {:title => nil, :content => nil}}

        response.should render_template "edit"
        flash.now[:info].should eql "The following languages were updated but still have warnings:<br><br>- #{content_module.language.name}"
      end
    end

    context "one or more of the autofire emails are invalid" do
      it "should go back to the edit page with an appropriate message" do
        language = @movement.languages.first
        email = FactoryGirl.create(:autofire_email, :action_page => @action_page, :language => language)

        put :update, :id => @action_page.id,
                     :movement_id => @movement.id,
                     :action_sequence_id => @action_sequence.id,
                     :autofire_emails => {language.iso_code.to_s => {'id' => email.id, 'enabled' => true, 'subject' => nil, 'body' => nil}}

        response.should render_template "edit"
        flash.now[:info].should eql "The following languages were updated but still have warnings:<br><br>- #{language.name}"
      end
    end

    context "both autofire emails and content modules have errors" do
      it "should go back to the edit page with an appropriate message" do
        language = @movement.languages.first
        email = FactoryGirl.create(:autofire_email, :action_page => @action_page, :language => language)
        content_module = FactoryGirl.create(:accordion_module)
        FactoryGirl.create(:content_module_link, :page => @action_page, :content_module => content_module)

        put :update, :id => @action_page.id,
                     :movement_id => @movement.id,
                     :action_sequence_id => @action_sequence.id,
                     :content_modules => {"#{content_module.id}" => {:title => nil, :content => nil}},
                     :autofire_emails => {language.iso_code.to_s => {'id' => email.id, 'enabled' => true, 'subject' => nil, 'body' => nil}}

        response.should render_template "edit"
        flash.now[:info].should eql "The following languages were updated but still have warnings:<br><br>- #{content_module.language.name}<br>- #{email.language.name}"
      end
    end

    it "should update autofire emails for each language" do
      @action_page.possible_languages.each do |language|
        AutofireEmail.find_or_create_by_action_page_id_and_language_id(@action_page.id, language.id)
      end

      l1_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language1.id)
      l2_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language2.id)
      l3_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language3.id)

      put :update, :id => @action_page.id,
                   :movement_id => @movement.id,
                   :action_sequence_id => @action_sequence.id,
                   :autofire_emails => {'en' => {'id' => l1_autofire_email.id,
                                                 'enabled' => true,
                                                 'subject' => 'Hi There',
                                                 'body' => 'Email is nice.',
                                                 'from' => 'banana@hammock.com',
                                                 'reply_to' => 'coconut@bongos.com'},
                                        'pt' => {'id' => l2_autofire_email.id,
                                                 'enabled' => true,
                                                 'subject' => 'pt Hi There',
                                                 'body' => 'pt Email is nice.',
                                                 'from' => 'banana@hammock.com',
                                                 'reply_to' => 'coconut@bongos.com'},
                                        'fr' => {'id' => l3_autofire_email.id,
                                                 'enabled' => true,
                                                 'subject' => 'fr Hi There',
                                                 'body' => 'fr Email is nice.',
                                                 'from' => 'banana@hammock.com',
                                                 'reply_to' => 'coconut@bongos.com'}}

      l1_autofire_email.reload
      l1_autofire_email.enabled.should be_true
      l1_autofire_email.subject.should eql "Hi There"
      l1_autofire_email.body.should eql "Email is nice."
      l1_autofire_email.from.should eql "banana@hammock.com"
      l1_autofire_email.reply_to.should eql "coconut@bongos.com"
      l2_autofire_email.reload
      l2_autofire_email.enabled.should be_true
      l2_autofire_email.subject.should eql "pt Hi There"
      l2_autofire_email.body.should eql "pt Email is nice."
      l2_autofire_email.from.should eql "banana@hammock.com"
      l2_autofire_email.reply_to.should eql "coconut@bongos.com"
      l3_autofire_email.reload
      l3_autofire_email.enabled.should be_true
      l3_autofire_email.subject.should eql "fr Hi There"
      l3_autofire_email.body.should eql "fr Email is nice."
      l3_autofire_email.from.should eql "banana@hammock.com"
      l3_autofire_email.reply_to.should eql "coconut@bongos.com"
    end
  end

  describe "responding to GET new" do
    before do
      @action_page = FactoryGirl.create(:action_page)
      @movement = @action_page.action_sequence.campaign.movement
      @movement.default_language = @movement.languages.first
    end

    it "should render the new template" do
      get :new, :movement_id => @movement.id, :action_sequence_id => @action_page.action_sequence.id
      response.should render_template(:new)
    end
  end

  describe "responding to GET unlink_content_module" do
    it "should unlink a module and replace it with a clone" do
      first_page = FactoryGirl.create(:action_page)
      second_page = FactoryGirl.create(:action_page)
      petition = FactoryGirl.create(:petition_module, :signatures_goal => 1111)
      first_link = ContentModuleLink.create!(:page => first_page, :content_module => petition, :layout_container => "sidebar")

      second_page.content_module_links.create!(:content_module => FactoryGirl.create(:html_module), :layout_container => "sidebar")
      broken_link = second_page.content_module_links.create!(:page => second_page, :content_module => petition, :layout_container => "sidebar")
      second_page.content_module_links.create!(:page => second_page, :content_module => FactoryGirl.create(:html_module), :layout_container => "sidebar")
      broken_link.position.should == 1

      get :unlink_content_module, :id => second_page.id,
          :movement_id => second_page.movement.id,
          :content_module_id => petition.id

      second_page.reload
      second_page.should have(3).content_module_links
      broken_link.reload
      broken_link.layout_container.should == :sidebar
      broken_link.position.should == 1
      broken_link.content_module.signatures_goal.should == 1111
      broken_link.content_module.id.should_not == petition.id

      first_page.reload
      first_page.should have(1).content_module_links
      first_page.content_modules.first.id.should == petition.id
    end
  end

  describe "rendering the edit page" do
    before :each do
      @action_page = FactoryGirl.create(:action_page)
      @movement = @action_page.action_sequence.campaign.movement
      @movement.default_language = @movement.languages.first
    end

    it "should render an empty hash of modules per language if rendering the page for the first time" do
      get :edit, {
        :movement_id => @movement.id,
        :id => @action_page.id
      }

      @action_page.possible_languages.each do |l|
        assigns(:action_page).content_modules.should be_empty
      end
    end

    it "should render the existing modules for the given page" do
      language = @movement.default_language
      html_module_head = FactoryGirl.create(:html_module, :language => language)
      html_module_sidebar = FactoryGirl.create(:html_module, :language => language)
      @action_page.content_module_links.create!(:layout_container => ContentModule::HEADER, :content_module => html_module_head)
      @action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => html_module_sidebar)

      get :edit, {
        :movement_id => @movement.id,
        :id => @action_page.id
      }

      assigns(:action_page).content_modules.should =~ [ html_module_head, html_module_sidebar ]
      assigns(:action_page).modules_for_container_and_language(ContentModule::SIDEBAR, language).should =~ [ html_module_sidebar ]
    end

    it "should render blank modules for a new language" do
      language = @movement.default_language
      html_module_head = FactoryGirl.create(:html_module, :language => language)
      html_module_sidebar_1 = FactoryGirl.create(:html_module, :language => language)
      html_module_sidebar_2 = FactoryGirl.create(:html_module, :language => language)
      @action_page.content_module_links.create!(:layout_container => ContentModule::HEADER,  :content_module => html_module_head)
      @action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => html_module_sidebar_1)
      @action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => html_module_sidebar_2)

      new_language = FactoryGirl.create(:language)
      @movement.movement_locales.create! :language => new_language, :default => false

      get :edit, {
        :movement_id => @movement.id,
        :id => @action_page.id
      }

      assigns(:action_page).modules_for_container_and_language(ContentModule::HEADER, new_language).size.should == 1
      assigns(:action_page).modules_for_container_and_language(ContentModule::SIDEBAR, new_language).size.should == 2
      assigns(:action_page).modules_for_container_and_language(ContentModule::MAIN, new_language).size.should == 0
      assigns(:action_page).modules_for_container_and_language(ContentModule::FOOTER, new_language).size.should == 0
    end


    describe "two movements have pages with the same name" do
      before do
        @allout = FactoryGirl.create(:movement, :name => "AllOut")
        @movement = FactoryGirl.create(:movement, :name => "Movement")

        @allout_campaign = FactoryGirl.create(:campaign, :movement => @allout)
        @movement_campaign = FactoryGirl.create(:campaign, :movement => @movement)

        @allout_action_sequence = FactoryGirl.create(:action_sequence, :campaign => @allout_campaign)
        @movement_action_sequence = FactoryGirl.create(:action_sequence, :campaign => @movement_campaign)

        @allout_donate_page = FactoryGirl.create(:action_page, :name => 'Donate', :action_sequence => @allout_action_sequence)
        @movement_donate_page = FactoryGirl.create(:action_page, :name => 'Donate', :action_sequence => @movement_action_sequence)
      end

      it "should render the page that belongs to AllOut" do
        get :edit, {
          :movement_id => @allout.friendly_id,
          :id => @allout_donate_page.friendly_id
        }

        assigns(:action_page).name.should eql 'Donate'
        assigns(:action_page).movement.should eql @allout
        assigns(:action_page).action_sequence.should eql @allout_action_sequence
      end

      it "should render the page that belongs to Movement" do
        get :edit, {
          :movement_id => @movement.friendly_id,
          :id => @movement_donate_page.friendly_id
        }

        assigns(:action_page).name.should eql 'Donate'
        assigns(:action_page).movement.should eql @movement
        assigns(:action_page).action_sequence.should eql @movement_action_sequence
      end
    end

    describe 'autofire emails,' do
      before do
        FactoryGirl.create(:petition_module, :pages => [@action_page])
      end

      context 'action page,' do
        it "should create autofire emails for each language if they don't exist" do
          get :edit, { :movement_id => @movement.id, :id => @action_page.id }

          @action_page.possible_languages.each do |l|
            AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, l.id).should_not be_nil
          end
        end
      end

      context 'join page' do
        it "should not create autofire emails for each language if they don't exist" do
          join_page = FactoryGirl.create(:action_page, :name => "Join", :action_sequence => @action_page.action_sequence)
          join_module = FactoryGirl.create(:join_module, :pages => [join_page])
          get :edit, { :movement_id => @movement.id, :id => join_page.id }

          AutofireEmail.count.should == 0
        end
      end
    end
  end

  describe 'create preview' do
    it "should create duplicate action_page, content modules and autofire emails and redirect to preview" do
      content_module = FactoryGirl.create(:petition_module)
      create(:content_module_link, :page => @action_page, :content_module => content_module)
      another_action_page = create(:action_page, :action_sequence => @action_sequence)
      language = create(:english)
      page_count = ActionPage.unscoped.all.count

      @action_page.possible_languages.each do |language|
        AutofireEmail.find_or_create_by_action_page_id_and_language_id(@action_page.id, language.id)
      end
      l1_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language1.id)
      l2_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language2.id)
      l3_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language3.id)
      put :create_preview, :id => @action_page.id,
                            :movement_id => @movement.id,
                            :action_page => {:name => "new name"},
                            :content_modules => {"#{content_module.id}" => {:title => "Hello", :content => "World"}},
                            :autofire_emails => {@language1.iso_code => {'id' => l1_autofire_email.id,
                                                          'enabled' => true,
                                                          'subject' => 'Hi There',
                                                          'body' => 'Email is nice.',
                                                          'from' => 'banana@hammock.com',
                                                          'reply_to' => 'coconut@bongos.com'},
                                                 @language2.iso_code => {'id' => l2_autofire_email.id,
                                                          'enabled' => true,
                                                          'subject' => 'pt Hi There',
                                                          'body' => 'pt Email is nice.',
                                                          'from' => 'banana@hammock.com',
                                                          'reply_to' => 'coconut@bongos.com'},
                                                 @language3.iso_code => {'id' => l3_autofire_email.id,
                                                          'enabled' => true,
                                                          'subject' => 'fr Hi There',
                                                          'body' => 'fr Email is nice.',
                                                          'from' => 'banana@hammock.com',
                                                          'reply_to' => 'coconut@bongos.com'}}
      ActionPage.unscoped.all.count.should == page_count + 1

      preview_action_page = ActionPage.unscoped.last
      preview_action_page.content_modules.first.title = "Hello"
      preview_action_page.content_modules.first.content = "World"
      preview_action_page.name = "new name"
      @action_page.reload
      @action_page.position.should == 1
      preview_action_page.position.should == 3
      @action_page.name.should_not == "new name"
      @action_page.content_modules.first.title.should_not == "Hello"
      @action_page.content_modules.first.content.should_not == "World"
      @action_page.autofire_emails.where(:language_id => @language1.id).first.subject.should_not == "Hi There"
      @action_page.autofire_emails.where(:language_id => @language2.id).first.subject.should_not == "pt Hi There"
      @action_page.autofire_emails.where(:language_id => @language3.id).first.subject.should_not == "fr Hi There"
      preview_action_page.autofire_emails.where(:language_id => @language1.id).first.subject.should == "Hi There"
      preview_action_page.autofire_emails.where(:language_id => @language2.id).first.subject.should == "pt Hi There"
      preview_action_page.autofire_emails.where(:language_id => @language3.id).first.subject.should == "fr Hi There"
      preview_action_page.live_page_id.should == @action_page.id
      preview_action_page.content_modules.size == @action_page.content_modules.size
      preview_action_page.autofire_emails.size == @action_page.autofire_emails.size

      response.body.should == "/admin/movements/#{@movement.slug}/action_pages/#{preview_action_page.slug}/preview"
    end
  end

  describe 'preview' do
    it "it should prepare preview" do
      content_module = FactoryGirl.create(:petition_module)
      create(:content_module_link, :page => @action_page, :content_module => content_module)
      another_action_page = create(:action_page, :action_sequence => @action_sequence)
      language = create(:english)
      page_count = ActionPage.unscoped.all.count

      @action_page.possible_languages.each do |language|
        AutofireEmail.find_or_create_by_action_page_id_and_language_id(@action_page.id, language.id)
      end
      l1_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language1.id)
      l2_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language2.id)
      l3_autofire_email = AutofireEmail.find_by_action_page_id_and_language_id(@action_page.id, @language3.id)
      put :create_preview, :id => @action_page.id,
          :movement_id => @movement.id,
          :action_page => {:name => "new name"},
          :content_modules => {"#{content_module.id}" => {:title => "Hello", :content => "World"}},
          :autofire_emails => {@language1.iso_code => {'id' => l1_autofire_email.id,
                                                       'enabled' => true,
                                                       'subject' => 'Hi There',
                                                       'body' => 'Email is nice.',
                                                       'from' => 'banana@hammock.com',
                                                       'reply_to' => 'coconut@bongos.com'},
                               @language2.iso_code => {'id' => l2_autofire_email.id,
                                                       'enabled' => true,
                                                       'subject' => 'pt Hi There',
                                                       'body' => 'pt Email is nice.',
                                                       'from' => 'banana@hammock.com',
                                                       'reply_to' => 'coconut@bongos.com'},
                               @language3.iso_code => {'id' => l3_autofire_email.id,
                                                       'enabled' => true,
                                                       'subject' => 'fr Hi There',
                                                       'body' => 'fr Email is nice.',
                                                       'from' => 'banana@hammock.com',
                                                       'reply_to' => 'coconut@bongos.com'}}
      ActionPage.unscoped.all.count.should == page_count + 1

      preview_action_page = ActionPage.unscoped.last
      get :preview, :movement_id => @movement.id, :id => preview_action_page.id
      assigns[:action_page].id.should == preview_action_page.id
      assigns[:movement].id.should == @movement.id
      response.should render_template "preview"
      response.should render_template "_base"
    end
  end
end
