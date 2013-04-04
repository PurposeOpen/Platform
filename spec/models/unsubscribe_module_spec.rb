#encoding: utf-8
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

describe UnsubscribeModule do

  before do
    @allout_action_page = FactoryGirl.create(:action_page)
    @allout = @allout_action_page.movement
    @allout_module = FactoryGirl.create(:unsubscribe_module, :pages => [@allout_action_page])
    
    @therules_action_page = FactoryGirl.create(:action_page)
    @therules = @therules_action_page.movement
    @therules_module = FactoryGirl.create(:unsubscribe_module, :pages => [@therules_action_page])
  end

  it "should flag a user as non member of a movement" do
    user = FactoryGirl.create(:user, :email => "bob@example.com", :movement => @allout, :is_member => true)

    @allout_module.take_action(user, {}, @allout_action_page)

    User.find_by_email_and_movement_id("bob@example.com", @allout.id).is_member.should be_false
  end

  it "should flag a user as non member of the movement associated with the module only" do
    bob_email = "bob@example.com"
    allout_user = FactoryGirl.create(:user, :email => bob_email, :movement => @allout, :is_member => true)
    FactoryGirl.create(:user, :email => bob_email, :movement => @therules, :is_member => true)

    @allout_module.take_action(allout_user, {}, @allout_action_page)

    User.find_by_email_and_movement_id(bob_email, @allout.id).is_member.should be_false
    User.find_by_email_and_movement_id(bob_email, @therules.id).is_member.should be_true
  end

  it "should create an Unsubscribe event" do
    user = FactoryGirl.create(:user, :email => "bob@example.com", :movement => @allout, :is_member => true)

    @allout_module.take_action(user, {}, @allout_action_page)

    UserActivityEvent.unsubscriptions.where(:user_id => user.id).first.should_not be_nil
  end

  it "should associate the unsubscribe event with the email that directed the user to the unsubscribe page" do
    user = FactoryGirl.create(:user, :email => "bob@example.com", :movement => @allout, :is_member => true)
    email = FactoryGirl.create(:email)

    @allout_module.take_action(user, {:email => email}, @allout_action_page)

    UserActivityEvent.unsubscriptions.where(:user_id => user.id, :email_id => email.id).count.should eql 1
  end
end
