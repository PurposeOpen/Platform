require "spec_helper"

describe Api::MovementsController do
  before do
    @english = FactoryGirl.create :english
    @us_locale = @english
    @follow_links = {:facebook => 'facebook_url', :twitter => 'twitter_url', :youtube => 'youtube_url'}
    @allout = FactoryGirl.create :movement, :languages => [@us_locale]
    @allout_homepage = @allout.homepage
    @allout_homepage_content = FactoryGirl.create(
      :homepage_content,
      :homepage => @allout_homepage,
      :language => @english,
      :banner_text => "HAVE JOINED THE MOVEMENT",
      :banner_image => "equality_everywhere.png",
      :join_headline => "ADDING PEOPLE POWER TO THE HISTORIC FIGHT FOR LGBT EQUALITY",
      :join_message => "The members of AllOut.org - gay and straight, bi and transgender - are building a world where we can all live freely and be embraced for who we are. Will you join the movement?",
      :follow_links => @follow_links,
      :footer_navbar => "<ul><li><a href=''>About</a></li></ul>",
      :header_navbar => "<ul><li><a href=''>More about us</a></li></ul>"
    )
    @allout.default_language = @us_locale
    @movement_locale = @allout.movement_locales.first
    @movement_language = @movement_locale.language
  end

  describe 'Display language recommendations' do
    it "should not recommend languages which do not have complete homepage contents" do
      us_locale = @english
      spanish = create(:spanish)
      follow_links = {:facebook => 'facebook_url', :twitter => 'twitter_url', :youtube => 'youtube_url'}
      bowled_out = FactoryGirl.create :movement, :languages => [@us_locale, spanish]
      bowled_out_homepage = bowled_out.homepage
      bowled_out_homepage_content = FactoryGirl.create(
          :homepage_content,
          :homepage => bowled_out_homepage,
          :language => @english,
          :banner_text => "HAVE JOINED THE MOVEMENT",
          :banner_image => "equality_everywhere.png",
          :join_headline => "ADDING PEOPLE POWER TO THE HISTORIC FIGHT FOR LGBT EQUALITY",
          :join_message => "The members of AllOut.org - gay and straight, bi and transgender - are building a world where we can all live freely and be embraced for who we are. Will you join the movement?",
          :follow_links => @follow_links,
          :footer_navbar => "<ul><li><a href=''>About</a></li></ul>",
          :header_navbar => "<ul><li><a href=''>More about us</a></li></ul>"
      )

      bowled_out.default_language = @us_locale
      home_page_content_incomplete = FactoryGirl.create(
          :homepage_content,
          :homepage => bowled_out_homepage,
          :language => spanish,
          :banner_text => "",
          :banner_image => "",
          :join_headline => "ADDING PEOPLE POWER TO THE HISTORIC FIGHT FOR LGBT EQUALITY",
          :join_message => "The members of AllOut.org - gay and straight, bi and transgender - are building a world where we can all live freely and be embraced for who we are. Will you join the movement?",
          :follow_links => @follow_links,
          :footer_navbar => "<ul><li><a href=''>About</a></li></ul>",
          :header_navbar => "<ul><li><a href=''>More about us</a></li></ul>"
      )
      get :show, :locale => :en, :movement_id => bowled_out.id, :format => "json"
      data = ActiveSupport::JSON.decode(response.body)
      data["recommended_languages_to_display"].length.should == 1
      data["languages"].length.should == 2
    end
  end

  describe 'featured content,' do
    before do
      @movement = FactoryGirl.create :movement, :languages => [@english]
    end

    it 'should return featured content collection and module data' do
      carousel = FactoryGirl.create(:featured_content_collection, :name => 'Carousel', :featurable => @movement.homepage)
      carousel_module = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => carousel, :position => 0)
      carousel_module_2 = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => carousel, :position => 1)
      featured_actions = FactoryGirl.create(:featured_content_collection, :name => 'Featured Actions', :featurable => @movement.homepage)
      featured_action_module = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => featured_actions, :position => 0)
      featured_action_module_2 = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => featured_actions, :position => 1)

      get :show, :id => @english.iso_code, :locale => @english.iso_code, :movement_id => @movement.id, :format => "json"

      data = ActiveSupport::JSON.decode(response.body)

      data["featured_contents"]["Carousel"].should_not be_nil
      data["featured_contents"]["FeaturedActions"].should_not be_nil

      data["featured_contents"]["Carousel"][0]["id"].should == carousel_module.id
      data["featured_contents"]["Carousel"][1]["id"].should == carousel_module_2.id
      data["featured_contents"]["FeaturedActions"][0]["id"].should == featured_action_module.id
      data["featured_contents"]["FeaturedActions"][1]["id"].should == featured_action_module_2.id
    end

    it 'should return featured content collection and module data by language' do
      spanish = FactoryGirl.create(:spanish)
      @allout.languages << spanish
      @allout.save!
      carousel = FactoryGirl.create(:featured_content_collection, :name => 'Carousel', :featurable => @allout_homepage)
      carousel_module = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => carousel)
      carousel_module_2 = FactoryGirl.create(:featured_content_module, :language => spanish, :featured_content_collection => carousel)
      featured_actions = FactoryGirl.create(:featured_content_collection, :name => 'Featured Actions', :featurable => @allout_homepage)
      featured_action_module = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => featured_actions)
      featured_action_module_2 = FactoryGirl.create(:featured_content_module, :language => spanish, :featured_content_collection => featured_actions)

      get :show, :id => spanish.iso_code, :locale => spanish.iso_code, :movement_id => @allout.id, :format => "json"

      data = ActiveSupport::JSON.decode(response.body)

      data["featured_contents"]["Carousel"].size.should == 1
      data["featured_contents"]["FeaturedActions"].size.should == 1

      data["featured_contents"]["Carousel"][0]["id"].should == carousel_module_2.id
      data["featured_contents"]["FeaturedActions"][0]["id"].should == featured_action_module_2.id
    end

    it 'should return featured content modules sorted by position' do
      carousel = FactoryGirl.create(:featured_content_collection, :name => 'Carousel', :featurable => @allout_homepage)
      carousel_module = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => carousel, :position => 1)
      carousel_module_2 = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => carousel, :position => 0)

      get :show, :id => @movement_language.iso_code, :locale => @movement_language.iso_code, :movement_id => @allout.id, :format => "json"

      data = ActiveSupport::JSON.decode(response.body)

      data["featured_contents"]["Carousel"][0]['id'].should == carousel_module_2.id
      data["featured_contents"]["Carousel"][1]['id'].should == carousel_module.id
    end

    it 'should only return featured content modules that are valid' do
      carousel = FactoryGirl.create(:featured_content_collection, :name => 'Carousel', :featurable => @allout_homepage)
      carousel_module_1 = FactoryGirl.create(:featured_content_module, :language => @english, :featured_content_collection => carousel)
      carousel_module_2 = FactoryGirl.build(:featured_content_module, :language => @english, :featured_content_collection => carousel)
      carousel_module_2.title = nil

      carousel_module_2.save!(:validate => false)
      get :show, :id => @movement_language.iso_code, :locale => @movement_language.iso_code, :movement_id => @allout.id, :format => "json"

      data = ActiveSupport::JSON.decode(response.body)

      carousel_module_2.valid_with_warnings?.should be_false
      data["featured_contents"]["Carousel"].size.should eql 1
      data["featured_contents"]["Carousel"][0]['id'].should == carousel_module_1.id
    end

  end

  it "the returning json should contain Movement information" do
    get :show, :locale => :en, :id => @movement_language.iso_code, :movement_id => @allout.id, :format => "json"

    data = ActiveSupport::JSON.decode(response.body)
    data["banner_text"].should == @allout_homepage_content.banner_text
    data["banner_image"].should == @allout_homepage_content.banner_image
    data["join_headline"].should == @allout_homepage_content.join_headline
    data["join_message"].should == @allout_homepage_content.join_message
    data["follow_links"].should == JSON.parse(@follow_links.to_json)
    data["footer_navbar"].should == @allout_homepage_content.footer_navbar
    data["header_navbar"].should == @allout_homepage_content.header_navbar
    data["languages"].should == [{"iso_code" => @us_locale.iso_code, "name" => @us_locale.name, "native_name" => @us_locale.native_name, "is_default" => (@us_locale == @allout.default_language)}]
  end

  it "should replace the MEMBERCOUNT token with the current member count on the banner_text" do
    french = FactoryGirl.create(:french)
    languages = [@english, french]
    movement = FactoryGirl.create(:movement, :languages => languages)
    movement.default_language = @english
    MemberCountCalculator.init(movement, 1000000)
    languages.each do |lang|
      FactoryGirl.create(:homepage_content,
                     :homepage => movement.homepage,
                     :language => lang,
                     :banner_text => "OMG, {MEMBERCOUNT} members!",
      )
    end
    get :show, :id => @english.iso_code, :format => "json", :locale => :en, :movement_id => movement.id
    data = ActiveSupport::JSON.decode(response.body)
    data["banner_text"].should == "OMG, <span class='member_count'>1,000,000</span> members!"

    get :show, :id => french.iso_code, :format => "json", :locale => :en, :movement_id => movement.id
    data = ActiveSupport::JSON.decode(response.body)
    data["banner_text"].should == "OMG, <span class='member_count'>1 000 000</span> members!"
  end

  context "registering click events on the homepage" do
    it "should create a user activity event for the click event on a link to the homepage" do
      user = FactoryGirl.create(:user, :movement => @allout)
      email = FactoryGirl.create(:email)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

      get :show, :id => @movement_language.iso_code, :locale => :en, :movement_id => @allout.id, :format => "json",
          :t => tracking_hash, :page_type => "Homepage"

      UserActivityEvent.where(:movement_id => @allout.id, :user_id => user.id, :email_id => email.id,
          :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :page_id => nil).count.should == 1
    end

    it "should allow the creation of duplicate user activity events for the click event on a link to the homepage" do
      user = FactoryGirl.create(:user, :movement => @allout)
      email = FactoryGirl.create(:email)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")
      FactoryGirl.create(:email_clicked_activity, :user => user, :email => email, :page_id => nil,
          :movement => @allout, :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s)

      get :show, :id => @movement_language.iso_code, :locale => :en, :movement_id => @allout.id, :format => "json",
          :t => tracking_hash, :page_type => "Homepage"

      UserActivityEvent.where(:movement_id => @allout.id, :user_id => user.id, :email_id => email.id,
          :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :page_id => nil).count.should == 2
    end
  end

  context "registering click events on an action page" do
    before do
      @campaign = FactoryGirl.create(:campaign, :movement => @allout)
      @action_sequence = FactoryGirl.create(:action_sequence, :campaign => @campaign)
      @page = FactoryGirl.create(:action_page, :action_sequence => @action_sequence, :name => "Pretty page")
    end

    it "should create a user activity event for the click event on a link to an action page" do
      user = FactoryGirl.create(:user, :movement => @allout)
      email = FactoryGirl.create(:email)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

      get :show, :id => @movement_language.iso_code, :locale => :en, :movement_id => @allout.id, :format => "json",
          :t => tracking_hash, :page_type => "ActionPage", :page_id => @page.friendly_id

      UserActivityEvent.where(:movement_id => @allout.id, :user_id => user.id, :email_id => email.id,
          :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :page_id => @page.id).count.should == 1
    end

    it "should allow the creation of duplicate user activity events for the click event on a link to an action page" do
      user = FactoryGirl.create(:user, :movement => @allout)
      email = FactoryGirl.create(:email)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")
      FactoryGirl.create(:email_clicked_activity, :user => user, :email => email, :page_id => @page.id,
          :movement => @allout)

      get :show, :id => @movement_language.iso_code, :locale => :en, :movement_id => @allout.id, :format => "json",
          :t => tracking_hash, :page_type => "ActionPage", :page_id => @page.friendly_id

      UserActivityEvent.where(:movement_id => @allout.id, :user_id => user.id, :email_id => email.id,
          :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :page_id => @page.id).count.should == 2
    end
  end

  context "registering click events on a content page" do
    before do
      @content_page_collection = FactoryGirl.create(:content_page_collection, :movement => @allout)
      @page = FactoryGirl.create(:content_page, :content_page_collection => @content_page_collection, :name => "About")
    end

    it "should create a user activity event for the click event on a link to a content page" do
      user = FactoryGirl.create(:user, :movement => @allout)
      email = FactoryGirl.create(:email)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")

      get :show, :id => @movement_language.iso_code, :locale => :en, :movement_id => @allout.id, :format => "json",
          :t => tracking_hash, :page_type => "ContentPage", :page_id => @page.friendly_id

      UserActivityEvent.where(:movement_id => @allout.id, :user_id => user.id, :email_id => email.id,
          :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :page_id => @page.id).count.should == 1
    end

    it "should allow the creation of duplicate user activity events for the click event on a link to a content page" do
      user = FactoryGirl.create(:user, :movement => @allout)
      email = FactoryGirl.create(:email)
      tracking_hash = Base64.urlsafe_encode64("userid=#{user.id},emailid=#{email.id}")
      FactoryGirl.create(:email_clicked_activity, :user => user, :email => email, :page_id => @page.id,
          :movement => @allout)

      get :show, :id => @movement_language.iso_code, :locale => :en, :movement_id => @allout.id, :format => "json",
          :t => tracking_hash, :page_type => "ContentPage", :page_id => @page.friendly_id

      UserActivityEvent.where(:movement_id => @allout.id, :user_id => user.id, :email_id => email.id,
          :activity => UserActivityEvent::Activity::EMAIL_CLICKED.to_s, :page_id => @page.id).count.should == 2
    end
  end

  context 'show for preview' do
    it 'should return movement with homepage draft if draft_homepage_id is present' do
      featured_content_collection = create(:featured_content_collection, :name => 'SomeFC', :featurable => @allout.homepage)
      featured_content_modules = [create(:featured_content_module, :featured_content_collection => featured_content_collection)]
      draft = @allout.homepage.duplicate_for_preview({
        :homepage_content => {@allout.homepage.homepage_contents.first.iso_code => {:join_headline => 'Preview headline'}},
        :featured_content_modules => {
        @allout.homepage.featured_content_modules.first.id => {:title => 'Preview featured content title'}
      }}.with_indifferent_access)

      get :show, :locale => :en, :movement_id => @allout.id, :draft_homepage_id => draft.id, :format => "json"

      data = ActiveSupport::JSON.decode(response.body).with_indifferent_access
      data[:join_headline].should ==  'Preview headline'
      data[:featured_contents]['SomeFC'].first[:title].should == 'Preview featured content title'
    end
  end
end
