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
require "ostruct"

describe PetitionModule do
  def validated_petition_module(attrs)
    default_attrs = {active: 'true'}
    pm = FactoryGirl.build(:petition_module, default_attrs.merge(attrs))
    pm.valid?
    pm
  end

  describe 'defaults' do
    it "should have comments enabled by default" do
      petition = PetitionModule.new
      petition.comments_enabled.should be_true
    end

    it "should not reset comments enabled if there is already a setting for this option" do
      pm = FactoryGirl.create(:petition_module, :comments_enabled => false)
      ContentModule.find(pm.id).comments_enabled.should be_false
    end

    it "should be active by default" do
      petition = PetitionModule.new
      petition.active.should be_true
    end
  end

  it "should return a url-encoded crowdring url" do
    petition = validated_petition_module(:title => 'A very popular action!')
    petition.send(:crowdring_campaign_endpoint, 'http://crowdring.org', 'Land India').to_s.should == "http://crowdring.org/campaign/Land%20India/campaign-member-count"
  end

  describe "if crowdring_url is set for movement" do
    let(:petition) {validated_petition_module(:title => 'A very popular action!')}

    before do
      Rails.cache.clear
    end

    context "signatures" do
      it "should not get crowdring_member_count if crowdring_campaign_name is not present" do
        action_page = FactoryGirl.create(:action_page, :crowdring_campaign_name => "", :movement => create(:movement, :crowdring_url => "http://some-url"))
        action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

        petition.should_not_receive(:crowdring_member_count)
        petition.signatures.should == 0
      end

      it "should not get crowdring_member_count if crowdring_url is not present" do
        action_page = FactoryGirl.create(:action_page, :crowdring_campaign_name => "aasd", :movement => create(:movement, :crowdring_url => ""))
        action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

        petition.should_not_receive(:crowdring_member_count)
        petition.signatures.should == 0
      end

      it "should fetch the crowdring_member_count from crowdring and add with petition signatures" do
        action_page = FactoryGirl.create(:action_page, :crowdring_campaign_name => "campaign1", :movement => create(:movement, :crowdring_url => "http://some-url"))
        action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

        petition.take_action(FactoryGirl.create(:user), {}, action_page)
        mock_http_response = StringIO.new('{"count" : 12}')
        petition.should_receive(:open).and_return(mock_http_response)
        petition.signatures.should == 13
      end

      it "crowring count should be 0 if Net:HTTP returns a empty response" do
        action_page = FactoryGirl.create(:action_page, :crowdring_campaign_name => "campaign2", :movement => create(:movement, :crowdring_url => "http://some-url"))
        action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

        mock_http_response = ''
        petition.should_receive(:open).and_return(mock_http_response)
        petition.signatures.should == 0
      end

      it "crowring count should be 0 if Net:HTTP throws error" do
        action_page = FactoryGirl.create(:action_page, :crowdring_campaign_name => "campaign2", :movement => create(:movement, :crowdring_url => "http://some-url"))
        action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

        petition.should_receive(:open).and_raise(EOFError)
        petition.signatures.should == 0
      end

      it "should fetch the crowdring_member_count from cache if present and add with petition signatures" do
        action_page = FactoryGirl.create(:action_page, :crowdring_campaign_name => "campaign3", :movement => create(:movement, :crowdring_url => "http://some-url"))
        Rails.cache.write(URI.parse("http://some-url/campaign/campaign3/campaign-member-count"), 11)
        action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

        petition.take_action(FactoryGirl.create(:user), {}, action_page)
        Net::HTTP.should_not_receive(:get_response)
        petition.signatures.should == 12
      end
    end

  end

  describe "serializing to json" do
    it "includes the current signatures count value" do
      petition = validated_petition_module(:title => 'A very popular action!')
      action_page = FactoryGirl.create(:action_page)
      action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

      petition.take_action(FactoryGirl.create(:user), {}, action_page)

      petition.as_json[:signatures].should == 1
    end

    it "should include comment data" do
      petition = FactoryGirl.create(:petition_module, :comment_label => 'Comment label',
          :comment_text => 'Comment text', :comments_enabled => true)

      json = JSON.parse(petition.to_json)
      json['options']['comment_label'].should == 'Comment label'
      json['options']['comment_text'].should == 'Comment text'
      json['options']['comments_enabled'].should == true
    end

    it_should_behave_like "content module with disabled content", :petition_module
  end

  it "should know how many signatures have been collected" do
    petition = validated_petition_module(:title => 'A very popular action!')
    action_page = FactoryGirl.create(:action_page)
    action_page.content_module_links.create!(:layout_container => ContentModule::SIDEBAR, :content_module => petition)

    3.times { FactoryGirl.create(:petition_signature, :content_module => petition, :action_page => action_page, :user => FactoryGirl.create(:user)) }

    petition.signatures.should == 3
  end

  describe "validation" do
    it "should warn about comment label and text if comments are enabled" do
      petition = PetitionModule.new
      petition.should_not be_valid_with_warnings
      petition.errors[:comment_label].any?.should be_true
    end

    it "should require a title between 3 and 128 characters" do
      validated_petition_module(:title => "Save the kittens!").should be_valid_with_warnings
      validated_petition_module(:title => "X" * 128).should be_valid_with_warnings
      validated_petition_module(:title => "X" * 129).should_not be_valid_with_warnings
      validated_petition_module(:title => "AB").should_not be_valid_with_warnings
    end

    it "should require a button text between 1 and 64 characters" do
      validated_petition_module(:button_text => "Save the kittens!").should be_valid_with_warnings
      validated_petition_module(:button_text => "X" * 64).should be_valid_with_warnings
      validated_petition_module(:button_text => "X" * 65).should_not be_valid_with_warnings
      validated_petition_module(:button_text => "").should be_valid_with_warnings
    end

    it "attribute setter should set target to 0 if blank or nil, and it should be valid without warnings" do
      pm = validated_petition_module(:signatures_goal => nil, :thermometer_threshold => 0)
      pm.signatures_goal.should == 0
      pm.should be_valid_with_warnings
    end

    it "should require a target greater than or equal to 0" do
       validated_petition_module(:signatures_goal => -1, :thermometer_threshold => 0).should_not be_valid_with_warnings
       validated_petition_module(:signatures_goal => 0, :thermometer_threshold => 0).should be_valid_with_warnings
       validated_petition_module(:signatures_goal => 1, :thermometer_threshold => 0).should be_valid_with_warnings
    end

    it "should require a thermometer threshold between 0 and the target value inclusive" do
      validated_petition_module(:signatures_goal => 100, :thermometer_threshold => 0).should be_valid_with_warnings
      validated_petition_module(:signatures_goal => 100, :thermometer_threshold => 50).should be_valid_with_warnings
      validated_petition_module(:signatures_goal => 100, :thermometer_threshold => 100).should be_valid_with_warnings
      validated_petition_module(:signatures_goal => 100, :thermometer_threshold => 110).should_not be_valid_with_warnings
    end

    it "should require a petition statement" do
      validated_petition_module(:button_text => "Save the kittens!").should be_valid_with_warnings
      validated_petition_module(:button_text => "X" * 64).should be_valid_with_warnings
      validated_petition_module(:button_text => "").should be_valid_with_warnings
    end

    it "should required disabled title/content if disabled" do
      validated_petition_module(active: 'true', disabled_title: '', disabled_content:
        '').should be_valid_with_warnings
      validated_petition_module(active: 'false', disabled_title: '', disabled_content:
        'bar').should_not be_valid_with_warnings
      validated_petition_module(active: 'false', disabled_title: 'foo', disabled_content:
        '').should_not be_valid_with_warnings
      validated_petition_module(active: 'false', disabled_title: 'foo', disabled_content:
        'bar').should be_valid_with_warnings
    end
  end

  describe "taking action" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @pm = FactoryGirl.create(:petition_module)
      @page = FactoryGirl.create(:action_page)
      FactoryGirl.create(:sidebar_module_link, :content_module => @pm, :page => @page)
    end

    it "should save a petition signature with a comment" do
      action_info = {:comment => 'This is a comment'}
      @pm.take_action(@user, action_info, @page)
      petition_signature = PetitionSignature.find_by_user_id_and_page_id(@user.id, @page.id)
      petition_signature.comment.should == 'This is a comment'
    end

    it "should create a user activity event without an email reference" do
      UserActivityEvent.should_receive(:action_taken!).with(@user, @page, @pm, an_instance_of(PetitionSignature), nil, nil)
      @pm.take_action(@user, {}, @page)
    end

    it "should create a user activity event with an email reference" do
      @email = FactoryGirl.create(:email)
      UserActivityEvent.should_receive(:action_taken!).with(@user, @page, @pm, an_instance_of(PetitionSignature), @email, nil)
      @pm.take_action(@user, {:email => @email}, @page)
    end

    it "should not create a user activity event if a petition signature already exists" do
      FactoryGirl.create(:petition_signature, :content_module_id => @pm.id, :user_id => @user.id, :page_id => @page.id)

      @pm.take_action(@user, {}, @page)

      uae = UserActivityEvent.all
      uae.count.should == 1
      uae.first.content_module.should == @pm
      uae.first.user.should == @user
      uae.first.page.should == @page
    end

  end

  describe "handling duplicates" do
    it "should do nothing if the ask/user combo has been seen before" do
      user = FactoryGirl.create(:user, :email => 'noone@example.com')
      ask = FactoryGirl.create(:petition_module)
      petition_signature = OpenStruct.new
      PetitionSignature.stub(:new).and_return(petition_signature)
      PetitionSignature.stub_chain(:where, :count).and_return(1)

      petition_signature.should_not_receive(:save)
      ask.take_action(user, {}, FactoryGirl.create(:action_page))
    end
  end
end
