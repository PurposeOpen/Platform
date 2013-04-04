require "spec_helper"

describe Stats::TransparencyStats do
  def clear_all
    User.destroy_all
    Donation.destroy_all
    Transaction.destroy_all
    UserActivityEvent.destroy_all
  end

  before(:each) do
    Rails.cache.clear
    clear_all
    transparency_stats = Stats::TransparencyStats.new
    action_page = create(:action_page, name: 'join')
    movement = action_page.movement
    user = FactoryGirl.create(:user, :email => "email1@test.com", :movement => movement)
    user.subscribe_through_homepage!
    user1 = FactoryGirl.create(:user, :email => "email2@test.com", :movement => movement)
    user1.subscribe_through_homepage!
    user2 = FactoryGirl.create(:user, :email => "email3@test.com", :movement => movement)
    user2.subscribe_through_homepage!

    uae_user = UserActivityEvent.where(:user_id => user.id, :activity => "subscribed").last
    uae_user.created_at  = 1.week.ago + 2.day
    uae_user.save
    uae_user1 = UserActivityEvent.where(:user_id => user1.id, :activity => "subscribed").last
    uae_user1.created_at  = 2.years.ago
    uae_user1.save
    uae_user2 = UserActivityEvent.where(:user_id => user2.id, :activity => "subscribed").last
    uae_user2.created_at  = 1.year.ago + 2.day
    uae_user2.save

    transaction_d = FactoryGirl.create(:transaction, :amount_in_cents => 5000, :created_at => 4.hours.ago,  :updated_at => 4.hours.ago, :donation => FactoryGirl.create(:donation, :amount_in_cents => 5000, :last_donated_at => 4.hours.ago, :created_at => 4.hours.ago, :user => user))
    transaction_w = FactoryGirl.create(:transaction, :amount_in_cents => 1000, :created_at => 1.week.ago + 1.day, :updated_at => 1.week.ago + 1.day, :donation => FactoryGirl.create(:donation, :amount_in_cents => 1000, :last_donated_at => 1.week.ago + 1.day, :created_at => 1.week.ago + 1.day, :user => user))
    transaction_m = FactoryGirl.create(:transaction, :amount_in_cents => 2000, :created_at => 1.month.ago + 1.day, :updated_at => 1.month.ago + 1.day, :donation => donation_m = FactoryGirl.create(:donation, :amount_in_cents => 2000, :last_donated_at => 1.month.ago + 1.day, :created_at => 1.month.ago + 1.day, :user => user1))
    transaction_y = FactoryGirl.create(:transaction, :amount_in_cents => 3000, :created_at => 1.year.ago + 2.day, :updated_at => 1.year.ago + 2.day, :donation => FactoryGirl.create(:donation, :amount_in_cents => 3000, :last_donated_at => 1.year.ago + 2.day, :created_at => 1.year.ago + 2.day, :user => user2))
    transaction_y1 = FactoryGirl.create(:transaction, :amount_in_cents => 3000, :created_at => 1.year.ago - 2.day, :updated_at => 1.year.ago - 2.day, :donation => FactoryGirl.create(:donation, :amount_in_cents => 3000, :last_donated_at => 1.year.ago - 2.day, :created_at => 1.year.ago - 2.day, :user => user1))
    transaction_y2 = FactoryGirl.create(:transaction, :amount_in_cents => 3000, :created_at => 2.years.ago, :updated_at => 2.years.ago, :donation => FactoryGirl.create(:donation, :amount_in_cents => 3000, :last_donated_at => 2.years.ago, :created_at => 2.years.ago, :user => user1))

    t_d_user = UserActivityEvent.where(:user_id => user.id, :activity => "action_taken", :user_response_id => transaction_d.id).last
    t_d_user.created_at  = 4.hours.ago
    t_d_user.save

    t_w_user = UserActivityEvent.where(:user_id => user.id, :activity => "action_taken", :user_response_id => transaction_w.id).last
    t_w_user.created_at  = 1.week.ago + 2.day
    t_w_user.save

    t_m_user = UserActivityEvent.where(:user_id => user1.id, :activity => "action_taken", :user_response_id => transaction_m.id).last
    t_m_user.created_at  = 1.month.ago + 2.day
    t_m_user.save

    t_y_user = UserActivityEvent.where(:user_id => user2.id, :activity => "action_taken", :user_response_id => transaction_y.id).last
    t_y_user.created_at  = 1.year.ago + 2.day
    t_y_user.save

    t_y1_user = UserActivityEvent.where(:user_id => user1.id, :activity => "action_taken", :user_response_id => transaction_y1.id).last
    t_y1_user.created_at  = 1.year.ago - 2.day
    t_y1_user.save

    t_y2_user = UserActivityEvent.where(:user_id => user1.id, :activity => "action_taken", :user_response_id => transaction_y2.id).last
    t_y2_user.created_at  = 2.years.ago
    t_y2_user.save

    @new_stats = transparency_stats.update
  end

  after do
    clear_all
  end

  it "should cache the results" do
    Rails.cache.clear

    stats = Stats::TransparencyStats.new
    stats.update

    cached_stats = Rails.cache.read("transparency_stats")
    cached_stats.should_not be_nil

    stats.should_not_receive(:actions_taken_count)
    Stats::TransparencyStats.new.update
  end

  it "should calculate the number of donations " do
    @new_stats[:day][:nb_donations].should eql 1
    @new_stats[:week][:nb_donations].should eql 2
    @new_stats[:month][:nb_donations].should eql 3
    @new_stats[:year][:nb_donations].should eql 4 + 36873
  end

  it "should calculate the number of actions taken" do
    # UserActivityEvent.all.each do |an_activity| p an_activity.inspect end
    @new_stats[:day][:actions_taken].should eql 7
    @new_stats[:week][:actions_taken].should eql 8
    @new_stats[:month][:actions_taken].should eql 9
    @new_stats[:year][:actions_taken].should eql 10 + 467997
  end

  it "should calculate the total donations made" do
    @new_stats[:day][:total_donations].should eql 50
    @new_stats[:week][:total_donations].should eql 60
    @new_stats[:month][:total_donations].should eql 80
    @new_stats[:year][:total_donations].should eql 110 + 1534247
  end

  it "should calculate the average donations made" do
    @new_stats[:day][:average_donations].should eql 50
    @new_stats[:week][:average_donations].should eql 30
    @new_stats[:month][:average_donations].should eql 26
    @new_stats[:year][:average_donations].should eql 41 #(11000+153424700)/(4+36873)
  end

  it "should calculate the number of donors" do
    @new_stats[:day][:donors].should eql 1
    @new_stats[:week][:donors].should eql 1
    @new_stats[:month][:donors].should eql 2
    @new_stats[:year][:donors].should eql 3 + 42779
  end

  it "should calculate the number of first time donors" do
    @new_stats[:day][:first_donors].should eql 0
    @new_stats[:week][:first_donors].should eql 1
    @new_stats[:month][:first_donors].should eql 1
    @new_stats[:year][:first_donors].should eql 2 + 18765
  end

  it "should calculate the number of new members" do
    @new_stats[:day][:new_members].should eql 0
    @new_stats[:week][:new_members].should eql 1
    @new_stats[:month][:new_members].should eql 1
    @new_stats[:year][:new_members].should eql 2 + 98803
  end
end
