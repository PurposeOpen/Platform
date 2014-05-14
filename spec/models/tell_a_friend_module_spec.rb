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

describe TellAFriendModule do

  def validated_tell_a_friend_module(attrs)
    tafm = FactoryGirl.create(:tell_a_friend_module)
    tafm.update_attributes attrs
    tafm.valid?
    tafm
  end

  it "should expose serialized options as attributes" do
    taf = TellAFriendModule.new
    options = [:share_url, :headline, :message, :facebook_enabled, :facebook_title, :facebook_description, :facebook_image_url, :twitter_enabled, :tweet, :email_enabled, :email_subject, :email_body, :include_action_counter, :action_counter_page_id]
    options.each do |option|
      taf.should respond_to option
    end
  end

  it "should set facebook, twitter, and email to 'enabled' by default" do
    taf = TellAFriendModule.new

    taf.options.should include({facebook_enabled: true, twitter_enabled: true, email_enabled: true})
  end

  it "should set include_action_counter to false by default" do
    taf = TellAFriendModule.new

    taf.options.should include({include_action_counter: false})
  end

  it "should not have warnings if twitter and email share options are disabled and share data is missing" do
    taf = build(:tell_a_friend_module, share_url: 'share_url', headline: 'headline', message: 'message', twitter_enabled: '0', email_enabled: '0')
    taf.should be_valid_with_warnings
  end

  it 'should have warnings if facebook_image_url is not given when facebook is enabled' do
    taf = build(:tell_a_friend_module, facebook_enabled: '1', facebook_image_url: nil)
    taf.should_not be_valid_with_warnings
  end

  it "should validate action counter page if action counter is included" do
    validated_tell_a_friend_module(include_action_counter: 'false').should be_valid_with_warnings
    validated_tell_a_friend_module(include_action_counter: 'true', action_counter_page_id: nil).should_not be_valid_with_warnings
    validated_tell_a_friend_module(include_action_counter: 'true', action_counter_page_id: '').should_not be_valid_with_warnings
    validated_tell_a_friend_module(include_action_counter: 'true', action_counter_page_id: 5).should be_valid_with_warnings
  end

  it "should trim whitespaces on validation" do
    taf = TellAFriendModule.new(share_url: ' Lorem ipsum dolor sit amet ', headline: ' Mauris sed tellus lectus ', message: ' Curabitur sed sapien justo ', facebook_title: ' Integer iaculis tellus non arcu ', facebook_description: ' Fusce vitae elit ', tweet: ' Aliquam erat volutpat ', email_subject: ' Donec a dolor ', email_body: ' Nullam porta faucibus massa ')
    taf.valid?
    taf.share_url.should eq 'Lorem ipsum dolor sit amet'
    taf.headline.should eq 'Mauris sed tellus lectus'
    taf.message.should eq 'Curabitur sed sapien justo'
    taf.facebook_title.should eq 'Integer iaculis tellus non arcu'
    taf.facebook_description.should eq 'Fusce vitae elit'
    taf.tweet.should eq 'Aliquam erat volutpat'
    taf.email_subject.should eq 'Donec a dolor'
    taf.email_body.should eq 'Nullam porta faucibus massa'
  end

  it "should not throw exception on validation if trimmed attribute is nil" do
    taf = TellAFriendModule.new
    expect { taf.valid? }.to_not raise_error(NoMethodError)
  end
end
