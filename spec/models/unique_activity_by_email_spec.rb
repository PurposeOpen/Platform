# == Schema Information
#
# Table name: unique_activity_by_emails
#
#  id          :integer          not null, primary key
#  email_id    :integer
#  activity    :string(64)
#  total_count :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe UniqueActivityByEmail do

  describe "#update!" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @user3 = FactoryGirl.create(:user)
      @email1 = FactoryGirl.create(:email)
      @email2 = FactoryGirl.create(:email)
      @email3 = FactoryGirl.create(:email)
    end

    it "should process unique activities and populate the aggregation table, and avoid creating duplicates on update" do
      FactoryGirl.create :activity, :user => @user1, :activity => 'action_taken', :email => @email1
      FactoryGirl.create :activity, :user => @user2, :activity => 'action_taken', :email => @email1


      Push.activity_class_for(:email_spammed).create(:movement_id => @email1.movement.id, :user_id => @user1.id, :push_id => @email1.push.id, :email_id => @email1.id)
      Push.activity_class_for(:email_viewed).create(:movement_id => @email1.movement.id, :user_id => @user1.id, :push_id => @email1.push.id, :email_id => @email1.id)
      Push.activity_class_for(:email_viewed).create(:movement_id => @email1.movement.id, :user_id => @user2.id, :push_id => @email1.push.id, :email_id => @email1.id)
      Push.activity_class_for(:email_viewed).create(:movement_id => @email1.movement.id, :user_id => @user3.id, :push_id => @email1.push.id, :email_id => @email1.id)


      create :activity, :user_id => @user1.id, :activity => 'subscribed', :email_id => @email2.id
      create :activity, :user_id => @user2.id, :activity => 'subscribed', :email_id => @email2.id

      Push.activity_class_for(:email_viewed).create(:movement_id => @email2.movement.id, :user_id => @user2.id, :push_id => @email2.push.id, :email_id => @email2.id)
      Push.activity_class_for(:email_viewed).create(:movement_id => @email2.movement.id, :user_id => @user3.id, :push_id => @email2.push.id, :email_id => @email2.id)
      Push.activity_class_for(:email_spammed).create(:movement_id => @email2.movement.id, :user_id => @user3.id, :push_id => @email2.push.id, :email_id => @email2.id)

      UniqueActivityByEmail.update!

      UniqueActivityByEmail.where(:email_id => @email1, :activity => 'action_taken').sum(:total_count).should == 2
      UniqueActivityByEmail.where(:email_id => @email1, :activity => 'email_spammed').sum(:total_count).should == 1
      UniqueActivityByEmail.where(:email_id => @email2, :activity => 'email_viewed').sum(:total_count).should == 2
      UniqueActivityByEmail.where(:email_id => @email2, :activity => 'email_spammed').sum(:total_count).should == 1
      UniqueActivityByEmail.where(:activity => 'email_viewed').sum(:total_count).should == 5
      UniqueActivityByEmail.where(:activity => 'email_spammed').sum(:total_count).should == 2
      UniqueActivityByEmail.where(:activity => 'subscribed').sum(:total_count).should == 2


      UniqueActivityByEmail.update!

      UniqueActivityByEmail.where(:email_id => @email1, :activity => 'action_taken').sum(:total_count).should == 2
      UniqueActivityByEmail.where(:email_id => @email1, :activity => 'email_spammed').sum(:total_count).should == 1
      UniqueActivityByEmail.where(:email_id => @email2, :activity => 'email_viewed').sum(:total_count).should == 2
      UniqueActivityByEmail.where(:email_id => @email2, :activity => 'email_spammed').sum(:total_count).should == 1
      UniqueActivityByEmail.where(:activity => 'email_viewed').sum(:total_count).should == 5
      UniqueActivityByEmail.where(:activity => 'email_spammed').sum(:total_count).should == 2
      UniqueActivityByEmail.where(:activity => 'subscribed').sum(:total_count).should == 2
    end

    it "should count multiple clicks from the same email by the same user once" do
      user = FactoryGirl.create(:user)
      email = FactoryGirl.create(:email)

      Push.activity_class_for(:email_clicked).create(:movement_id => email.movement.id, :user_id => user.id, :push_id => email.push.id, :email_id => email.id)
      Push.activity_class_for(:email_clicked).create(:movement_id => email.movement.id, :user_id => user.id, :push_id => email.push.id, :email_id => email.id)

      UniqueActivityByEmail.update!

      UniqueActivityByEmail.where(:email_id => email.id, :activity => 'email_clicked').sum(:total_count).should == 1
    end

    it "should count multiple views of the same email by the same user once" do
      user = FactoryGirl.create(:user)
      email = FactoryGirl.create(:email)

      Push.activity_class_for(:email_viewed).create(:movement_id => email.movement.id, :user_id => user.id, :push_id => email.push.id, :email_id => email.id)
      Push.activity_class_for(:email_viewed).create(:movement_id => email.movement.id, :user_id => user.id, :push_id => email.push.id, :email_id => email.id)

      UniqueActivityByEmail.update!

      UniqueActivityByEmail.where(:email_id => email.id, :activity => 'email_viewed').sum(:total_count).should == 1
    end

    it "should only process unique activities that happened after the last processing time" do
      UniqueActivityByEmail.delete_all

      Push.activity_class_for(:email_viewed).create(:movement_id => @email1.movement.id, :user_id => @user1.id, :push_id => @email1.push.id, :email_id => @email1.id, :created_at => 1.hours.ago)

      UniqueActivityByEmail.update!
      UniqueActivityByEmail.where(:activity => 'email_viewed').sum(:total_count).should == 1

      Push.activity_class_for(:email_viewed).create(:movement_id => @email1.movement.id, :user_id => @user2.id, :push_id => @email1.push.id, :email_id => @email1.id, :created_at => 2.hours.ago)

      UniqueActivityByEmail.update!
      UniqueActivityByEmail.where(:activity => 'email_viewed').sum(:total_count).should == 1
    end

    it "should refresh the updated_at field of an existing stat" do
      UniqueActivityByEmail.create!(:email_id => @email1.id, :activity=>"action_taken", :total_count => 1, :updated_at => 1.hour.ago)

      existing_stat = UniqueActivityByEmail.where(:email_id => @email1.id, :activity => 'action_taken').first
      last_updated_at = existing_stat.updated_at

      create :activity, :user_id => @user3.id, :activity => 'action_taken', :email_id => @email1.id, :created_at => 2.hours.from_now
      UniqueActivityByEmail.update!

      existing_stat.reload.updated_at.should > last_updated_at
    end
  end
end
