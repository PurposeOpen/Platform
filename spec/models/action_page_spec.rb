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

describe ActionPage do
  describe "self methods" do
    it "should return all action pages of types PetitionModule, DonationModule, EmailTargetsModule, JoinModule" do
      movement = create(:movement)
      petition_module1 = create(:petition_module)
      join_module = create(:join_module)
      donation_module = create(:donation_module)
      email_targets_module = create(:email_targets_module)

      content1 = create(:content_module_link, content_module: join_module, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: movement))))
      content2 = create(:content_module_link, content_module: petition_module1, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: movement))))
      content3 = create(:content_module_link, content_module: email_targets_module, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: movement))))
      content4 = create(:content_module_link, content_module: donation_module, page: create(:action_page, action_sequence: create(:action_sequence, campaign: create(:campaign, movement: movement))))
      result = [[content1.page.name, content1.page.id], [content2.page.name, content2.page.id], [content3.page.name, content3.page.id], [content4.page.name, content4.page.id]]
      ActionPage.page_options(movement.id, ["PetitionModule", "DonationModule", "EmailTargetsModule", "JoinModule"]).should be_same_array_regardless_of_order(result)
      ActionPage.page_options(movement.id, []).should == []
    end
  end

  describe "acts as list" do
    it "should be scoped to the containing action_sequence" do
      action_sequence = create(:action_sequence)
      another_action_sequence = create(:action_sequence)
      create(:action_page, action_sequence: another_action_sequence, name: "page1")
      create(:action_page, action_sequence: another_action_sequence, name: "page2")
      create(:action_page, action_sequence: another_action_sequence, name: "page3")

      first_page = create(:action_page, action_sequence: action_sequence, name: "page4")
      second_page = create(:action_page, action_sequence: action_sequence, name: "page5")

      first_page.position.should == 1
      second_page.position.should == 2
    end

    it "should not consider deleted pages when validating the pages' positions" do
      action_sequence = create(:action_sequence)

      page1 = create(:action_page, action_sequence: action_sequence, name: "page1", position: 1)
      page2 = create(:action_page, action_sequence: action_sequence, name: "page2", position: 2)
      page3 = create(:action_page, action_sequence: action_sequence, name: "page3", position: 3)
      page4 = build(:action_page, action_sequence: action_sequence, name: "page4", position: 1)

      page2.destroy
      page3.position = 2
      page3.valid?.should be_true
      page4.valid?.should be_false

    end

    it "should not allow creation of pages with blank movement attribute" do
      action_sequence = create(:action_sequence)
      page5 = build(:action_page, action_sequence: action_sequence, name: "page5", position: 1, movement_id: nil)
      page5.valid?.should be_false
      page5.errors.messages.should have_key(:movement_id)
    end

    it "should not consider preview pages when validating the pages' positions" do
      action_sequence = create(:action_sequence)
      page1 = create(:action_page, action_sequence: action_sequence, name: "page1", position: 1)
      page2 = create(:action_page, action_sequence: action_sequence, name: "page2", position: 2)
      page3 = create(:action_page, action_sequence: action_sequence, name: "page3", position: 3)
      page4 = create(:action_page, action_sequence: action_sequence, name: "page4", position: 3, live_action_page: page3)
      page5 = create(:action_page, action_sequence: action_sequence, name: "page5", position: 4, live_action_page: page4)
      page6 = create(:action_page, action_sequence: action_sequence, name: "page6", position: 6)
      page1.valid?.should be_true
      page2.valid?.should be_true
      page3.valid?.should be_true
      page4.valid?.should be_true
      page6.valid?.should be_true
      page6.position = 4
      page6.valid?.should be_true
      page6.position = 6
      page6.valid?.should be_true
      page6.position = 1
      page6.valid?.should be_false
    end
  end

  describe "validations" do
    before :each do
      @ps = create(:action_sequence)
    end

    it "should require a name between 3 and 64 characters" do
      build(:action_page).should be_valid
      build(:action_page, name: "Save the kittens!", action_sequence: @ps).should be_valid
      build(:action_page, name: "12",                action_sequence: @ps).should have(1).error_on(:name)
      build(:action_page, name: "X" * 65,            action_sequence: @ps).should have(1).error_on(:name)
      build(:action_page, name: nil,                 action_sequence: @ps).should have(1).error_on(:name)
      build(:action_page, name: 'Sally',             action_sequence: nil).should have(1).error_on(:action_sequence)
    end

    it "should allow any characters for campaign pages" do
      create(:action_page, name: "This really ? would=not work well as a http:// URL", action_sequence: @ps).should be_valid
    end

    it "should not allow a duplicate name" do
      original = create(:action_page, name: "Original Name", action_sequence: @ps)
      build(:action_page, name: "Original Name", action_sequence: @ps).should_not be_valid
    end

    it "should allow a duplicate name if the original has been deleted" do
      original = create(:action_page, name: "Original Name", action_sequence: @ps)
      original.destroy
      duplicate = create(:action_page, name: "Original Name", action_sequence: @ps)
      duplicate.should be_valid
    end

    it "should allow a page to have a name that was previously used by another page" do
      page1 = create(:action_page, name: "Blank page", action_sequence: @ps)
      page1.save!

      page1.update_attributes name: "Important page"

      page2 = create(:action_page, name: "Blank page", action_sequence: @ps)
      page2.should be_valid
    end

    it "should have unique position within the action sequence if live_action_page is nil" do
      action_sequence = create(:action_sequence)
      action_page = create(:action_page, live_action_page: nil, position: 1, action_sequence: action_sequence)
      action_page1 = build(:action_page, live_action_page: nil, position: 1, action_sequence: action_sequence)
      action_page1.should_not be_valid
      action_page_with_live_action_page = build(:action_page, live_action_page: action_page, position: 1, action_sequence: action_sequence)
      action_page_with_live_action_page.should be_valid
    end
  end

  describe "ask_module" do
    it "knows if it has an ask module" do
      without = create(:action_page)
      without.has_an_ask?.should == false
      with = create(:action_page)
      with.content_modules << create(:petition_module)

      with.has_an_ask?.should == true
    end

    it "knows about the ask module for the movement's default language and specific languages" do
      l1, l2 = create(:language), create(:language)
      movement = create(:movement, languages: [l1, l2])
      movement.default_language = l2

      page = create(:action_page,
        action_sequence: create(:action_sequence,
          campaign: create(:campaign,
            movement: movement)))

      m1 = create(:petition_module, language: l1)
      m2 = create(:petition_module, language: l2)

      page.content_modules << m1
      page.content_modules << m2

      page.ask_module.should == m2
      page.ask_module_for_language(l1).should == m1
    end
  end

  describe "donation module" do
    it "knows if it has a donation module" do
      without = create(:action_page)
      without.content_modules << create(:petition_module)
      without.is_donation?.should == false

      with = create(:action_page)
      with.content_modules << create(:petition_module)
      with.content_modules << create(:donation_module)

      with.is_donation?.should == true
      with.has_counter?.should == true
    end

    it "knows if donation module is tax deductible" do
      page_with_tax_deductible_module = create(:action_page)
      page_with_tax_deductible_module.content_modules << create(:petition_module)
      page_with_tax_deductible_module.content_modules << create(:tax_deductible_donation_module)

      page_with_tax_deductible_module.is_tax_deductible_donation?.should be_true
    end

    it "knows if donation module is non tax deductible" do
      page_with_non_tax_deductible_module = create(:action_page)
      page_with_non_tax_deductible_module.content_modules << create(:petition_module)
      page_with_non_tax_deductible_module.content_modules << create(:non_tax_deductible_donation_module)

      page_with_non_tax_deductible_module.is_non_tax_deductible_donation?.should be_true
    end
  end

  it "knows if it has module with action counter" do
    page_with_module(:petition_module).should have_counter
    page_with_module(:email_targets_module).should have_counter
    page_with_module(:donation_module).should have_counter
    page_with_module(:join_module).should_not have_counter
  end

  def page_with_module(module_type)
    page = create(:action_page)
    page.content_modules << build(module_type)
    page
  end

  it "knows if it has a tell a friend module" do
    without = create(:action_page)
    without.content_modules << create(:html_module)
    without.is_tell_a_friend?.should == false

    with = create(:action_page)
    with.content_modules << create(:html_module)
    with.content_modules << create(:tell_a_friend_module)

    with.is_tell_a_friend?.should == true
  end

  describe "required user details" do
    it "should always store values as symbols" do
      page = create(:action_page)
      page.required_user_details = {first_name: "hidden"}
      page.required_user_details[:first_name].should == :hidden
    end
  end

  describe "non_hidden_user_details," do
    it "should return non-hidden user detail fields" do
      fields = {"first_name"      => "required",
                "last_name"       => "required",
                "country"         => "required",
                "postcode_number" => "required",
                "mobile_number"   => "optional",
                "home_number"     => "hidden",
                "suburb"          => "hidden",
                "street_address"  => "hidden"}.freeze

      non_hidden_fields = fields.dup.delete_if {|key, value| value == "hidden" }

      page = create(:action_page, required_user_details: fields)

      page.non_hidden_user_details.should == non_hidden_fields.merge(email: :required)
    end
  end

  describe "positioning of modules on the page" do
    before :each do
      @page = create(:action_page)

      @english = create(:english)
      @portuguese = create(:portuguese)
      @french = create(:french)

      @page.movement.movement_locales.create! language: @english, default: true
      @page.movement.movement_locales.create! language: @portuguese, default: false
      @page.movement.movement_locales.create! language: @french, default: false

      @m1 = create(:html_module, language: @english)
      @m2 = create(:html_module, language: @portuguese)
      @m3 = create(:html_module, language: @french)
      @m4 = create(:html_module, language: @french)
      @m5 = create(:html_module, language: @english)
      @m6 = create(:html_module, language: @french)
      @m7 = create(:html_module, language: @portuguese)

      @page.content_module_links.create! content_module: @m1, layout_container: ContentModule::MAIN
      @page.content_module_links.create! content_module: @m2, layout_container: ContentModule::MAIN
      @page.content_module_links.create! content_module: @m3, layout_container: ContentModule::SIDEBAR
      @page.content_module_links.create! content_module: @m4, layout_container: ContentModule::MAIN
      @page.content_module_links.create! content_module: @m5, layout_container: ContentModule::SIDEBAR
      @page.content_module_links.create! content_module: @m6, layout_container: ContentModule::HEADER
      @page.content_module_links.create! content_module: @m7, layout_container: ContentModule::HEADER
    end

    it "should not fail to retrieve modules if the page has no modules at all" do
      empty_page = create(:action_page)
      empty_page.action_sequence.campaign.movement.default_language = Language.find_by_iso_code("en")
      empty_page.modules_for_container_and_language(ContentModule::MAIN, create(:english)).should be_empty
    end

    it "should retrieve the modules in the main area by language" do
      @page.modules_for_container_and_language(ContentModule::MAIN, create(:english)).should == [ @m1 ]
      @page.modules_for_container_and_language(ContentModule::MAIN, @portuguese).should == [ @m2 ]
      @page.modules_for_container_and_language(ContentModule::MAIN, @french).should == [ @m4 ]
    end

    it "should retrieve the modules in the header area by language" do
      @page.modules_for_container_and_language(ContentModule::HEADER, create(:french)).should == [ @m6 ]
      @page.modules_for_container_and_language(ContentModule::HEADER, @portuguese).should == [ @m7 ]
      @page.modules_for_container_and_language(ContentModule::HEADER, @english).should == []
    end

    it "should retrieve the modules in the sidebar area by language" do
      @page.modules_for_container_and_language(ContentModule::SIDEBAR, create(:french)).should == [ @m3 ]
      @page.modules_for_container_and_language(ContentModule::SIDEBAR, @english).should == [ @m5 ]
      @page.modules_for_container_and_language(ContentModule::SIDEBAR, @portuguese).should == []
    end

    it "should generate new modules if modules exist for the default language but not the requested language" do
      new_language = create(:language)
      def_language = @page.movement.default_language

      @page.movement.movement_locales.create! language: new_language, default: false

      @page.modules_for_container_and_language(ContentModule::MAIN, new_language).count.should ==
        @page.modules_for_container_and_language(ContentModule::MAIN, def_language).count

      @page.modules_for_container_and_language(ContentModule::SIDEBAR, new_language).count.should ==
        @page.modules_for_container_and_language(ContentModule::SIDEBAR, def_language).count

      @page.modules_for_container_and_language(ContentModule::HEADER, new_language).count.should ==
        @page.modules_for_container_and_language(ContentModule::HEADER, def_language).count
    end
  end

  it "avoids overwriting view count when receiving high traffic" do
    first_ref = create(:action_page)
    second_ref = ActionPage.find(first_ref.id)
    first_ref.add_view!
    second_ref.add_view!
    first_ref.reload.views.should == 2
  end

  describe "#valid_main_content_modules" do
    it "should returns all main content modules that pass ActiveRecord validations" do
      page = create(:action_page, content_modules: [create(:html_module)])
      page.content_module_links.create!(layout_container: :main_content, content_module: create(:past_campaign_module))
      page.content_module_links.create!(layout_container: :main_content, content_module: create(:past_campaign_module))

      page.valid_main_content_modules.size.should eql 2
    end

    it "should returns all header content modules that pass ActiveRecord validations" do
      page = create(:action_page, content_modules: [create(:html_module)])
      page.content_module_links.create!(layout_container: :header_content, content_module: create(:past_campaign_module))
      page.content_module_links.create!(layout_container: :header_content, content_module: create(:past_campaign_module))

      page.valid_header_content_modules.size.should eql 2
    end
  end

  describe "#autofire_email_for_language" do
    before :each do
      @page = create(:action_page)
    end

    it "should retrieve autofire email for language" do
      english = create(:english)
      spanish = create(:spanish)

      @page.autofire_emails.create!(action_page_id: @page.id, language_id: english.id)
      @page.autofire_emails.create!(action_page_id: @page.id, language_id: spanish.id)

      @page.autofire_email_for_language(spanish).should eql AutofireEmail.find_by_action_page_id_and_language_id(@page.id, spanish.id)
    end
  end

  describe "#cache_key" do
    it "should generate different cache keys even if different pages have the same friendly id" do
      page_1 = create(:action_page, name: "the page")
      page_2 = create(:action_page, name: "the page")

      page_1.cache_key.should_not eql page_2.cache_key
    end
  end

  describe "process_action_taken_by" do
    it "should find its action-able module and delegate to it" do
      page = create(:action_page)
      default_language = page.movement.default_language

      petition = create(:petition_module, language: default_language)
      html = create(:html_module)
      member = create(:user, language: default_language)
      email = create(:autofire_email, enabled: false, action_page: page, language: default_language)

      page.content_modules = [html, petition]
      page.save

      lambda { page.process_action_taken_by(member) }.should change(petition.petition_signatures, :count).from(0).to(1)
    end

    describe "autofire email" do
      before do
        AppConstants.stub(:no_reply_address) { 'test@example.com' }
      end

      it "should not be sent from non-ask pages" do
        page = create(:action_page)
        language = page.movement.languages.first
        tell_a_friend = create(:tell_a_friend_module, language: language, pages: [page])
        member = create(:user, language: language)
        email = create(:autofire_email, enabled: true, action_page: page, language: language)

        ActionMailer::Base.deliveries.size.should == 0
        SendgridMailer.should_not_receive(:user_email)

        page.process_action_taken_by(member)
      end

      it "when enabled should deliver an email to the user taking an action" do
        petition = create(:petition_module)
        page = create(:action_page, content_modules: [petition])
        member = create(:user, language: page.movement.languages.first)
        email = create(:autofire_email,
            enabled: true,
            subject: "Autofire email",
            action_page: page,
            language: page.movement.languages.first,
            from: "noreply@yourdomain.com")

        page.process_action_taken_by(member)

        ActionMailer::Base.deliveries.size.should == 1
        mail = ActionMailer::Base.deliveries.first
        mail.from.should eql ['noreply@yourdomain.com']
        mail.to.should eql [AppConstants.no_reply_address]
        mail.subject.should eql "Autofire email"
      end

      it "when disabled should not deliver an email to the user taking an action" do
        petition = create(:petition_module)
        page = create(:action_page, content_modules: [petition])
        member = create(:user, language: page.movement.languages.first)
        email = create(:autofire_email, enabled: false, action_page: page, language: page.movement.languages.first)

        ActionMailer::Base.deliveries.size.should == 0
        SendgridMailer.should_not_receive(:user_email)

        page.process_action_taken_by(member)
      end

      it "should use additional tokens provided by the generated user response after an action is taken" do
        donation = double
        donation.stub(:respond_to?).and_return(true)
        donation.stub(:autofire_tokens).and_return({"RECEIPT" => "$10 donated to movement!"})
        ActionPageObserver.stub(:update).and_return(true)

        donation_module = create(:donation_module)
        DonationModule.any_instance.stub(:take_action).and_return(donation)

        page = create(:action_page, content_modules: [donation_module])
        language = page.movement.default_language
        donation_module.update_attributes(language: language)
        member = create(:user, language: language)
        email = create(:autofire_email,
            enabled: true,
            subject: "Autofire email",
            action_page: page,
            language: language,
            from: "noreply@yourdomain.com",
            body: "Here's your receipt: {RECEIPT|}")

        page.process_action_taken_by(member, {currency: :usd, payment_method: :paypal, amount: 1000})

        ActionMailer::Base.deliveries.size.should == 1
        mail = ActionMailer::Base.deliveries.first
        mail.from.should eql ['noreply@yourdomain.com']
        mail.to.should eql [AppConstants.no_reply_address]
        mail.subject.should eql "Autofire email"
        mail.should have_body_text("Here's your receipt: $10 donated to movement!")
      end
    end
  end

  describe '#set_up_autofire_emails' do
    before do
      @page = create(:action_page)
    end
    context 'join page,' do
      it 'should not set up autofire emails' do
        join_module = create(:join_module, pages: [@page])
        @page.content_modules(true) # reload association to avoid cache issues

        @page.set_up_autofire_emails
        AutofireEmail.count.should == 0
      end
    end

    context 'not a join page' do
      it 'should set up autofire emails for each language' do
        create(:petition_module, pages: [@page])
        spanish = create(:spanish)
        french = create(:french)

        @page.movement.languages << [spanish, french]
        @page.movement.save

        @page.set_up_autofire_emails
        AutofireEmail.count.should == 3
      end
    end
  end

  describe "gets pre-seeded with a module" do
    it "should create the module in the sidebar container when the page itself is created" do
      page = create(:action_page, seeded_module: "petition_module")
      modules = page.reload.content_modules
      modules.size.should == 1

      modules.first.tap do |mod|
        mod.should be_kind_of(PetitionModule)
        mod.content_module_links.size.should == 1
        mod.content_module_links.first.layout_container.should == :sidebar
      end
    end

    it "should not pre-seed any modules if the given seeded_module string is blank" do
      create(:action_page, seeded_module: "").content_modules.should be_empty
      create(:action_page, seeded_module: nil).content_modules.should be_empty
    end
  end

  describe "converted to json format" do
    before :each do
      @english = create(:english)
      portuguese = create(:portuguese)
      movement = create(:movement, languages: [portuguese, @english])

      @page = create(:action_page, name: "Cool page", movement: movement)
      @page.action_sequence.campaign.update_attributes(movement: movement)

      header_module_in_english = create(:html_module, content: "html content", language: @english)
      header_module_in_portuguese = create(:html_module, content: "conteudo html", language: portuguese)
      create(:content_module_link, page: @page, content_module: header_module_in_english, layout_container: ContentModule::HEADER)
      create(:content_module_link, page: @page, content_module: header_module_in_portuguese, layout_container: ContentModule::HEADER)
    end

    it "should use movement's default language if no language is specified when retrieving page's content" do
      @page.movement.default_iso_code.should == "pt"
      json = @page.as_json

      json[:id].should eql @page.id
      json[:name].should eql "Cool page"
      json[:header_content_modules].first['content'].should eql "conteudo html"
      json[:main_content_modules].should eql []
      json[:sidebar_content_modules].should eql []
      json[:footer_content_modules].should eql []
    end

    it "should use specified language when retrieving page's content" do
      json = @page.as_json language: "en"

      json[:id].should eql @page.id
      json[:name].should eql "Cool page"
      json[:header_content_modules].first['content'].should eql "html content"
      json[:main_content_modules].should eql []
      json[:sidebar_content_modules].should eql []
      json[:footer_content_modules].should eql []
    end

    it "should include TellAFriend facebook information" do
      taf_module_in_english = create(:tell_a_friend_module,
                                                 facebook_title: "Facebook Share!",
                                                 facebook_description: "Share with friends",
                                                 facebook_image_url: "image url",
                                                 language: @english)
      create(:content_module_link, page: @page, content_module: taf_module_in_english, layout_container: ContentModule::SIDEBAR)

      json = @page.as_json language: "en"

      json[:sidebar_content_modules].first['options']['facebook_title'].should eql "Facebook Share!"
      json[:sidebar_content_modules].first['options']['facebook_description'].should eql "Share with friends"
      json[:sidebar_content_modules].first['options']['facebook_image_url'].should eql "image url"
    end

    it "should include the target number of signatures goal and thermometer threshold for a Petition module" do
      petition = create(:petition_module, signatures_goal: 100, thermometer_threshold: 25)
      create(:content_module_link, page: @page, content_module: petition, layout_container: ContentModule::SIDEBAR)

      json = @page.as_json language: "en"

      json[:sidebar_content_modules].first['options']['signatures_goal'].should eq 100
      json[:sidebar_content_modules].first['options']['thermometer_threshold'].should eq 25
    end

    it 'should footer content modules' do
      footer_content_module = create(:html_module, content: 'This is the footer content')
      create(:content_module_link, content_module: footer_content_module, page: @page, layout_container: ContentModule::FOOTER)
      json = @page.as_json language: "en"
      json[:footer_content_modules].size.should == 1
      json[:footer_content_modules][0]['content'].should == 'This is the footer content'
    end

    it "includes required field information with the page" do
      @page.required_user_details = { first_name: :required }
      @page.save
      json = @page.as_json

      json['first_name'].should eql 'required'
      json[:email].should eql :required
    end

    it "should include the number of actions that have been taken on that page" do
      english = create(:language)
      portuguese = create(:language)
      page = create(:action_page)
      petition_in_english = create(:petition_module, language: english, pages: [page])
      petition_in_portuguese = create(:petition_module, language: portuguese, pages: [page])
      american_user = create(:user, email: "john@us.com", movement: page.movement, language: english)
      british_user = create(:user, email: "john@uk.co.uk", movement: page.movement, language: english)
      brazilian_user = create(:user, email: "joao@br.com.br",  movement: page.movement, language: portuguese)

      petition_in_english.take_action(american_user, {}, page)
      petition_in_english.take_action(british_user, {}, page)
      petition_in_portuguese.take_action(brazilian_user, {}, page)

      json = page.as_json
      json[:actions_taken_count].should eql 3
    end

    it "should include share counts for a taf module" do
      taf = create(:tell_a_friend_module)
      create(:content_module_link, page: @page, content_module: taf, layout_container: ContentModule::SIDEBAR)
      @page.content_modules(true)

      create(:facebook_share, page_id: @page.id)
      create(:twitter_share, page_id: @page.id)
      create(:email_share, page_id: @page.id)
      create(:email_share, page_id: @page.id)

      json = @page.as_json language: "en"

      json[:shares].should == { 'facebook' => 1,
                                'twitter'  => 1,
                                'email'    => 2 }
    end
  end

  describe "tafs for locale" do
    it "should retrieve all Tell A Friend content modules for a page and locale" do
      portuguese = create(:portuguese)
      spanish = create(:spanish)

      action_page = create(:action_page)
      create(:header_module_link, page: action_page)
      create(:sidebar_module_link, page: action_page)

      portuguese_taf_module_link = create(:taf_module_link, page: action_page)
      portuguese_taf_module_link.content_module.update_attributes(language: portuguese)

      spanish_taf_module_link = create(:taf_module_link, page: action_page)
      spanish_taf_module_link.content_module.update_attributes(language: spanish)

      action_page.tafs_for_locale(portuguese).should =~ [portuguese_taf_module_link.content_module]
    end
  end

  describe "initialize_defaults!" do
    it "should initialize with views and name" do
      action_page = build(:action_page, name: "Action Page", views: 10)
      action_page.initialize_defaults!
      action_page.views.should == 0
      action_page.name.should == "Action Page(1)"
    end

    it "should initialize with next version of name" do
      create(:action_page, name: "Action Page(1)")
      create(:action_page, name: "Action Page(3)")
      action_page = build(:action_page, name: "Action Page", views: 10)
      action_page.initialize_defaults!
      action_page.name.should == "Action Page(4)"
    end
  end

  describe "#link_existing_modules_to" do
    let!(:petition_page) { create(:action_page) }
    let!(:image_html_module) { create(:html_module) }
    let!(:text_html_module) { create(:html_module) }
    let!(:petition_module) { create(:petition_module) }
    let!(:petition_image_html_module_link) { create(:header_module_link, page: petition_page, content_module: image_html_module) }
    let!(:petition_text_html_module_link) { create(:header_module_link, page: petition_page, content_module: text_html_module) }
    let!(:petition_action_module_link) { create(:sidebar_module_link, page: petition_page, content_module: petition_module) }
    let!(:taf_page) { create(:action_page) }

    it "should return the newly linked content modules" do
      petition_page.link_existing_modules_to(taf_page, ContentModule::HEADER).should =~ [image_html_module, text_html_module]
    end

    it "should link all of the source page container's content modules that are not yet linked to the target page's container" do
      already_shared_html_module = create(:html_module)
      create(:header_module_link, page: petition_page, content_module: already_shared_html_module)
      create(:header_module_link, page: taf_page, content_module: already_shared_html_module)
      taf_page.content_modules(true)

      petition_page.link_existing_modules_to taf_page, ContentModule::HEADER
      taf_page.reload
      taf_page.content_modules.should =~ [already_shared_html_module, image_html_module, text_html_module]
    end

  end

  describe "#sibling_pages" do
    it "should find all sibling pages under the same action sequence" do
      action_sequence = create(:action_sequence)
      petition_page = create(:action_page, action_sequence: action_sequence)
      donation_page = create(:action_page, action_sequence: action_sequence)
      taf_page = create(:action_page, action_sequence: action_sequence)

      taf_page.sibling_pages.should =~ [petition_page, donation_page]
      petition_page.sibling_pages.should =~ [taf_page, donation_page]
      donation_page.sibling_pages.should =~ [taf_page, petition_page]
    end
  end

  describe 'update campaign' do
    let(:sometime_in_the_past) { Time.zone.parse '2001-01-01 01:01:01' }
    let(:campaign) { create(:campaign, updated_at: sometime_in_the_past) }
    let(:action_sequence) { create(:action_sequence, campaign: campaign) }

    it 'should touch campaign when added' do
      action_page = create(:action_page, action_sequence: action_sequence)
      campaign.reload.updated_at.should > sometime_in_the_past
    end

    it 'should touch campaign when updated' do
      action_page = create(:action_page, action_sequence: action_sequence)
      campaign.update_column(:updated_at, sometime_in_the_past)
      action_page.update_attributes(name: 'A new updated action page')
      campaign.reload.updated_at.should > sometime_in_the_past
    end

    it 'should not touch campaign for a cloned action page' do
      action_page = create(:action_page, action_sequence: action_sequence)
      campaign.update_column(:updated_at, sometime_in_the_past)
      cloned_action_page = create(:action_page, action_sequence: action_sequence, live_action_page: action_page)
      campaign.reload.updated_at.should == sometime_in_the_past
    end
  end

end
