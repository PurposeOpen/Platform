require "spec_helper"

describe EmailStatsTable do

  it "returns stats for the email" do
    email  = FactoryGirl.create(:email)
    movement = FactoryGirl.create(:movement)

    # values = []

    last_user = User.last
    user_id = last_user.nil? ? 65535 : last_user.id + 65536
    100.times do
      user_id += 1
      PushSentEmail.create :movement_id => email.movement.id, :user_id => user_id, :email_id => email.id, :push_id => email.blast.push.id
    end

    90.times do
      user_id += 1
      PushViewedEmail.create :movement_id => email.movement.id, :user_id => user_id, :email_id => email.id, :push_id => email.blast.push.id
    end
    50.times do
      user_id += 1
      PushClickedEmail.create :movement_id => email.movement.id, :user_id => user_id, :email_id => email.id, :push_id => email.blast.push.id
    end

    5.times do
      user_id += 1
      PushSpammedEmail.create :movement_id => email.movement.id, :user_id => user_id, :email_id => email.id, :push_id => email.blast.push.id
    end

    # updates the aggregate table
    UniqueActivityByEmail.update!

    stats_table = EmailStatsTable.new([email])
    stats_table.load_stats[email.id][:email_sent][:as_value].should == 100
    stats_table.load_stats[email.id][:email_sent][:as_percentage].should == "100%"

    stats_table.load_stats[email.id][:email_viewed][:as_value].should == 90
    stats_table.load_stats[email.id][:email_viewed][:as_percentage].should == "90%"

    stats_table.load_stats[email.id][:email_clicked][:as_value].should == 50
    stats_table.load_stats[email.id][:email_clicked][:as_percentage].should == "50%"

    stats_table.load_stats[email.id][:email_spammed][:as_value].should == 5
    stats_table.load_stats[email.id][:email_spammed][:as_percentage].should == "5%"
  end

  it "doesn't throw up with zero values" do
    email = FactoryGirl.create(:email)

    values = 10.times.map do
      PushSentEmail.create :movement_id => email.movement.id, :user_id => FactoryGirl.create(:user).id, :email_id => email.id, :push_id => email.blast.push.id
    end

    stats_table = EmailStatsTable.new([email])
    stats_table.load_stats[email.id][:email_viewed][:as_value].should == 0
    stats_table.load_stats[email.id][:email_viewed][:as_percentage].should == "0%"
  end

  it "should not count the same activity on the same object twice for a given user" do

    email = FactoryGirl.create(:email)
    user  = FactoryGirl.create(:user)

    values = 5.times.map do
      PushViewedEmail.create :movement_id => email.movement.id, :user_id => FactoryGirl.create(:user).id, :email_id => email.id, :push_id => email.blast.push.id
    end

    values += 2.times.map do
      PushViewedEmail.create :movement_id => email.movement.id, :user_id => user.id, :email_id => email.id, :push_id => email.blast.push.id
    end

    # updates the aggregate table
    UniqueActivityByEmail.update!

    stats_table = EmailStatsTable.new([email])
    stats_table.load_stats[email.id][:email_viewed][:as_value].should == 6

  end

  describe "#last_updated_at" do
    let(:email1) { FactoryGirl.create(:email) }
    let(:email2) { FactoryGirl.create(:email) }

    it "should return the latest date when the table has been updated" do
      latest_date = 1.hour.ago
      UniqueActivityByEmail.create!(:email_id => email1.id, :activity => "action_taken", :total_count => 1, :updated_at => latest_date)
      UniqueActivityByEmail.create!(:email_id => email2.id, :activity => "action_taken", :total_count => 1, :updated_at => 10.hours.ago)

      stats_table = EmailStatsTable.new([email1, email2])
      stats_table.load_stats[:last_updated_at].should.to_s == latest_date.to_s
    end

    it "returns null if stats have never been updated before" do
      stats_table = EmailStatsTable.new([email1, email2])
      stats_table.load_stats[:last_updated_at].should be_nil
    end
  end
end
