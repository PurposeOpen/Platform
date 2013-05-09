# == Schema Information
#
# Table name: movements
#
#  id                        :integer          not null, primary key
#  name                      :string(20)       not null
#  url                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  subscription_feed_enabled :boolean
#  created_by                :string(255)
#  updated_by                :string(255)
#  password_digest           :string(255)
#  slug                      :string(255)
#  crowdring_url             :string(255)
#

require "spec_helper"

describe Movement do
  describe 'create' do
    it 'should create MemberCountCalculator for the new movement' do
      new_movement = create(:movement)
      count = MemberCountCalculator.for_movement(new_movement)
      count.last_member_count.should == 0
      count.current.should == 0
    end
  end

  describe '#draft_homepages' do
    let(:allout) { create(:movement, :name => 'allout') }

    it 'should return [] if homepage drafts are not avaiable' do
      allout.draft_homepages.should be_empty
    end

    it 'should return draft homepages' do
      first_draft = allout.homepage.duplicate_for_preview
      last_draft = allout.homepage.duplicate_for_preview
      allout.draft_homepages.should == [first_draft, last_draft]
    end
  end

  describe '#existing_sources' do
    let(:allout) { FactoryGirl.create(:movement, :name => 'allout') }

    subject { allout.existing_sources }

    describe 'when there are no members' do
      it { should eql [] }
    end

    describe 'when members joined through a movement' do
      before { 3.times.each { FactoryGirl.create(:user, :source => :movement, :movement => allout) } }
      it { should eql [[:movement, 'movement']] }
    end

    describe 'when members come from different sources to the same movement' do
      before {[:movement, :allout_v3, :import].each {|source| FactoryGirl.create(:user, :source => source, :movement => allout) } }
      it { should =~ [[:movement, 'movement'], [:allout_v3, 'allout_v3'], [:import,'import']] }
    end

    describe 'when members come from different sources to different movements' do
      let(:walkfree) { FactoryGirl.create(:movement, :name => 'walkfree') }
      before do
        FactoryGirl.create(:user, :source => :movement, :movement => walkfree)
        FactoryGirl.create(:user, :source => :import, :movement => walkfree)
        FactoryGirl.create(:user, :source => :allout_v3, :movement => allout)
      end

      it { should eql [[:allout_v3, 'allout_v3']] }
    end
  end

  it "should set a default language" do
    english = FactoryGirl.create(:english)
    portuguese = FactoryGirl.create(:portuguese)
    movement = FactoryGirl.create(:movement, :languages => [english, portuguese])
    movement.default_language = english.id
    movement.default_language.should eql english
  end

  it "should list all non-default languages" do
    %w{ja es ru}.each {|code| FactoryGirl.create(:language, :iso_code => code)}
    movement = FactoryGirl.create(:movement, :languages => [], :iso_codes => %w{ja es ru})
    movement.update_attributes :default_iso_code => "ru"

    movement.default_language.iso_code.should == "ru"
    movement.non_default_languages.map(&:iso_code).should =~ %w{ja es}
  end

  it "should raise exception if trying to set default language that doesn't exist in movement" do
    english = FactoryGirl.create(:english)
    portuguese = FactoryGirl.create(:portuguese)
    movement = FactoryGirl.create(:movement, :languages => [english])
    lambda { movement.default_language = portuguese.id }.should raise_exception(RuntimeError)
  end

  it "should allow only one default language" do
    english = FactoryGirl.create(:english)
    portuguese = FactoryGirl.create(:portuguese)
    movement = FactoryGirl.create(:movement, :languages => [english, portuguese])
    movement.default_language = english.id
    movement.default_language = portuguese.id

    movement.movement_locales.default.size.should eql 1
    movement.default_language.should == portuguese
  end

  describe "validation" do

    let(:movement) { FactoryGirl.build(:movement) }

    it "should make sure URL is valid" do
      movement.update_attributes(:url => "")
      movement.errors[:url].should_not be_empty

      movement.update_attributes(:url => "zuh?")
      movement.errors[:url].should_not be_empty

      movement.update_attributes(:url => "http://allout.org")
      movement.errors[:url].should be_empty
    end
  end

  describe 'pushes,' do
    it "should return the movement's pushes" do
      movement = create(:movement)
      campaign = create(:campaign, :movement => movement)

      push_1 = create(:push, :campaign => campaign, :created_at => Time.now)
      push_2 = create(:push, :campaign => campaign, :created_at => 1.day.ago)
      push_3 = create(:push, :campaign => campaign, :created_at => 2.days.ago)

      movement.pushes.should =~ [push_1, push_2, push_3]
    end
  end

  describe "slugs" do
    it "should be slugged" do
      FactoryGirl.create(:movement, :name => "Foo Bar").friendly_id.should == "foo-bar"
    end

    it "should provide custom slugs for particular movements" do
      FactoryGirl.create(:movement, :name => "Movement One").friendly_id.should == "movement-one"
      FactoryGirl.create(:movement, :name => "Movement Two").friendly_id.should == "movement-two"
      FactoryGirl.create(:movement, :name => "Movement Three").friendly_id.should == "movement-three"
    end
  end

  describe "finding pages" do
    before :each do
      @allout = FactoryGirl.create(:movement, :name => "All Out")
      @campaign = FactoryGirl.create(:campaign, :movement => @allout)
      @action_sequence = FactoryGirl.create(:action_sequence, :campaign => @campaign)
      @content_page_collection = FactoryGirl.create(:content_page_collection, :movement => @allout)
      @action_page = FactoryGirl.create(:action_page, :action_sequence => @action_sequence, :name => "Cool Action")
      @content_page = FactoryGirl.create(:content_page, :content_page_collection => @content_page_collection, :name => "Cool Content")
    end

    it "should find preview pages of the respective movements when using find_page_unscoped" do
      action_page = create(:action_page, :action_sequence => @action_sequence, :live_page_id => @action_page.id, :name => "Cool Action")
      movement2 = create(:movement, :name => "Something")
      action_page_movement2 = FactoryGirl.create(:action_page, :movement => movement2, :name => "Cool Action")
      action_page_movement_preview = FactoryGirl.create(:action_page, :movement => movement2, :live_page_id => action_page_movement2.id, :name => "Cool Action")
      @allout.find_page_unscoped(action_page.id).should == action_page
      @allout.find_page_unscoped(action_page.slug).should == action_page
      movement2.find_page_unscoped(action_page.slug).should ==  action_page_movement_preview
      expect { @allout.find_page_unscoped("uncool-page") }.to raise_error
    end

    it "should raise a record not found error if no page is found" do
      expect { @allout.find_page("uncool-page") }.to raise_error
    end

    it "should find pages by id" do
      @allout.find_page(@action_page.id).should eql @action_page
      @allout.find_page(@content_page.id).should eql @content_page
    end

    it "should only find pages that belong to a given movement when searching by id" do
      walkfree = FactoryGirl.create(:movement, :name => "Walk Free")
      walkfree_collection = FactoryGirl.create(:content_page_collection, :movement => walkfree)
      walkfree_content_page = FactoryGirl.create(:content_page, :content_page_collection => walkfree_collection, :name => "Cool Content")

      expect { @allout.find_page(walkfree_content_page.id) }.to raise_error
    end

    it "should find action pages by their friendly id" do
      @allout.find_page("cool-action").should eql @action_page
    end

    it "should find content pages by their friendly id" do
      @allout.find_page("cool-content").should eql @content_page
    end

    it "should find pages with the same friendly id for different movements" do
      walkfree = FactoryGirl.create(:movement, :name => "Walk Free")
      walkfree_collection = FactoryGirl.create(:content_page_collection, :movement => walkfree)
      walkfree_content_page = FactoryGirl.create(:content_page, :content_page_collection => walkfree_collection, :name => "Cool Content")

      @allout.find_page("cool-content").should eql @content_page
      walkfree.find_page("cool-content").should eql walkfree_content_page
    end

    it "should not find pages after they have been renamed" do
      @action_page.update_attributes name: "Cooler page"
      expect { @allout.find_page("cool-action") }.to raise_error
    end

    it "should still find pages if the movement is renamed" do
      @allout.update_attributes name: "Chocolate"
      @allout.find_page("cool-action").should eql @action_page
    end
  end

  describe "unsubscribed_members" do
    before(:each) do
      @movement = create(:movement)
      @unsubscribed_user = create(:user, movement: @movement, is_member: false)
      @active_user = create(:user, movement: @movement, is_member: true)
      another_movement = create(:movement)
      create(:user, movement: another_movement, is_member: false)
      create(:user, movement: another_movement, is_member: true)
    end

    it "should return all unsubscribed members for the movement" do
      @movement.unsubscribed_members.should == [@unsubscribed_user]
    end
  end

  describe '#image_settings_for' do
    let(:movement) {create(:movement)}

    it 'should return {} if the settings are not available' do
      movement.image_settings_for(:facebook).should == {}
    end

    it 'should return for different modules' do
      settings = create(:image_settings, :movement => movement, :facebook_image_height => 132, :facebook_image_width => 98, :facebook_image_dpi => 43)
      fb_image_settings = movement.image_settings_for(:facebook)
      fb_image_settings[:image_height].should == 132
      fb_image_settings[:image_width].should == 98
      fb_image_settings[:image_dpi].should == 43
    end
  end
end
