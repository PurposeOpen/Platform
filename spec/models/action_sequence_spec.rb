# == Schema Information
#
# Table name: action_sequences
#
#  id                :integer          not null, primary key
#  campaign_id       :integer
#  name              :string(64)
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  created_by        :string(255)
#  updated_by        :string(255)
#  alternate_key     :integer
#  options           :text
#  published         :boolean
#  enabled_languages :text
#  slug              :string(255)
#

require "spec_helper"

describe ActionSequence do
  before :each do
    @campaign = FactoryGirl.build(:campaign)
  end

  describe "validations" do
    it "should require a name between 3 and 64 characters" do
      ActionSequence.new(name: "Save the kittens!", campaign: @campaign).should be_valid
      ActionSequence.new(name: "12", campaign: @campaign).should_not be_valid
      ActionSequence.new(name: "X" * 65, campaign: @campaign).should_not be_valid
      ActionSequence.new(name: nil, campaign: @campaign).should_not be_valid
    end
  end

  it "knows that it is static pages if campaign is nil" do
    FactoryGirl.build(:action_sequence, campaign: @campaign, name: "Not Static").should_not be_static
    FactoryGirl.build(:action_sequence, campaign: nil, name: "Static").should be_static
  end

  it "should not allow a duplicate name" do
    original = ActionSequence.create(name: "Original Name", campaign: @campaign)
    ActionSequence.new(name: "Original Name", campaign: @campaign).should_not be_valid
  end

  it "should allow a duplicate name if the original has been deleted" do
    original = ActionSequence.create(name: "Original Name", campaign: @campaign)
    original.destroy
    duplicate = ActionSequence.new(name: "Original Name", campaign: @campaign)
    duplicate.should be_valid
  end

  it "should return a reference to the first page in the sequence" do
    original = ActionSequence.create(name: "Original Name", campaign: @campaign)
    first_page = FactoryGirl.create(:action_page, name: "page1", action_sequence: original)
    second_page = FactoryGirl.create(:action_page, name: "page2", action_sequence: original)

    original.reload
    original.landing_page.should eql first_page
  end

  describe "defaults" do
    it "should have appropriate defaults" do
      action_sequence = ActionSequence.new
      action_sequence.tweet_text.should == "Why don't you check out this?"
      action_sequence.email_subject.should == "Check out this campaign"
      action_sequence.email_body.should == "Why don't you check out this?"
      action_sequence.facebook_image.should == "http://localhost:3000/images/blank_logo.png"
    end
  end

  it "should return the first taf content module in the action sequence" do
    english = FactoryGirl.create(:english)
    taf_module_link = FactoryGirl.create(:taf_module_link)
    taf = taf_module_link.content_module
    taf.update_attributes(language: english)
    action_sequence = taf_module_link.page.action_sequence
    html_module_link = FactoryGirl.create(:sidebar_module_link, page: FactoryGirl.create(:action_page, name: "Petition Page", action_sequence: action_sequence))

    action_sequence.first_taf(english).should == taf
  end

  describe "cache behavior" do
    before(:each) do
      Rails.cache.clear
      @campaign = FactoryGirl.create(:campaign, name: 'sign this')
      @action_sequence = FactoryGirl.create(:action_sequence, name: 'begin here', campaign: @campaign)
    end

    it "should load the action sequence from cache if found" do
      Rails.cache.write(@action_sequence.cache_key, @action_sequence)

      ActionSequence.should_not_receive(:find)
      ActionSequence.get_from_cache(@campaign, @action_sequence.friendly_id).should eql @action_sequence
    end

    it "should save the page to the cache on first find" do
      Rails.cache.read(@action_sequence.cache_key).should be_nil
      ActionSequence.get_from_cache(@campaign, @action_sequence.friendly_id).should eql @action_sequence
      Rails.cache.read(@action_sequence.cache_key).should eql @action_sequence
    end
  end


  describe "initialize_defaults!" do
    it "should initialize with next version of name" do
      create(:action_sequence, name: "Name(1)")
      create(:action_sequence, name: "Name(2)")
      action_sequence = build(:action_sequence, name: "Name", published: true)
      action_sequence.initialize_defaults!
      action_sequence.name.should == "Name(3)"
      action_sequence.published.should be_false
    end
  end

  describe "duplicate" do
    it "should duplicate action sequence with defaults overridden" do
      action_sequence_name = "Action Sequence(1)"
      action_sequence = create(:action_sequence, name: action_sequence_name)
      page_name_1 = "Page Name"
      page_name_2 = "Another Page Name(2)"
      duplicated_page_name_1 = "Page Name(1)"
      duplicated_page_name_2 = "Another Page Name(3)"
      action_page_1 = create(:action_page, action_sequence: action_sequence, name: page_name_1, views: 5)
      create(:autofire_email, action_page: action_page_1, from: "abcd@abcd.com")
      create(:action_page, action_sequence: action_sequence, name: page_name_2, views: 0)
      2.times { create(:content_module_link, page: action_page_1) }

      duplicated_action_sequence = action_sequence.duplicate
      duplicated_action_sequence.name.should == "Action Sequence(2)"
      duplicated_action_sequence.published.should be_false

      duplicated_action_sequence.action_pages.size.should == 2
      duplicated_action_sequence.action_pages.map(&:name).should be_same_array_regardless_of_order([duplicated_page_name_1, duplicated_page_name_2])
      duplicated_action_sequence.action_pages.map(&:views).should == [0, 0]

      action_page_with_content_modules_and_email = duplicated_action_sequence.action_pages.select { |action_page| action_page.name == duplicated_page_name_1 }.first
      action_page_without_content_modules = duplicated_action_sequence.action_pages.select { |action_page| action_page.name == duplicated_page_name_2 }.first
      action_page_with_content_modules_and_email.content_module_links.size.should == 2
      duplicated_content_modules = action_page_with_content_modules_and_email.content_module_links.map(&:content_module)
      duplicated_content_modules.size.should == 2
      duplicated_content_modules.map(&:id).should_not be_same_array_regardless_of_order(action_page_1.content_modules.map(&:id))
      action_page_with_content_modules_and_email.autofire_emails.size.should == 1
      action_page_with_content_modules_and_email.autofire_emails[0].from.should == "abcd@abcd.com"

      action_page_without_content_modules.content_module_links.should be_empty
      action_page_without_content_modules.content_modules.should be_empty
      action_page_without_content_modules.autofire_emails.should be_empty
    end
  end

  describe "action_pages_with_counter" do
    it "should return pages which have counters" do
      action_sequence = create(:action_sequence)
      petition_page = create(:action_page, name: 'Petition', action_sequence: action_sequence)
      petition_page.content_modules << build(:petition_module)
      donation_page = create(:action_page, name: 'Donation', action_sequence: action_sequence)
      donation_page.content_modules << build(:donation_module)
      join_page = create(:action_page, name: 'Join', action_sequence: action_sequence)
      join_page.content_modules << build(:join_module)

      action_sequence.action_pages_with_counter.should == [petition_page, donation_page]
    end
  end

  describe "language_enabled?" do
    before(:each) do
      @language_1, @language_2, @language_3 = create_list(:language, 3)
      @action_sequence = create(:action_sequence, enabled_languages: [@language_1.iso_code.to_s, @language_2.iso_code.to_s])
    end

    it "should return true if the language belongs to an action sequence" do
      @action_sequence.language_enabled?(@language_1).should be_true
      @action_sequence.language_enabled?(@language_2).should be_true
    end

    it "should return false if the language does not belong to an action sequence" do
      @action_sequence.language_enabled?(@language_3).should be_false
    end
  end

  describe 'update campaign' do
    let(:sometime_in_the_past) { Time.zone.parse '2001-01-01 01:01:01' }
    let(:campaign) { create(:campaign, updated_at: sometime_in_the_past) }

    it 'should touch campaign when added' do
      @action_sequence = create(:action_sequence, campaign: campaign)
      campaign.reload.updated_at.should > sometime_in_the_past
    end

    it 'should touch campaign when updated' do
      @action_sequence = create(:action_sequence, campaign: campaign)
      campaign.update_column(:updated_at, 3.days.ago)
      @action_sequence.update_attributes(name: 'A new updated action sequence')
      campaign.reload.updated_at.should > sometime_in_the_past
    end
  end
end
