# == Schema Information
#
# Table name: member_count_calculators
#
#  id                :integer          not null, primary key
#  current           :integer
#  last_member_count :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  movement_id       :integer          not null
#

require 'spec_helper'

describe MemberCountCalculator do
  it "should increment the member count by a given factor" do
    movement = FactoryGirl.create(:movement)
    calc = MemberCountCalculator.init(movement, 10)
    calc.current.should eql 10

    subscribed = double(:count => 15)
    User.stub(:subscribed_to) { subscribed }
    calc.update_count!.should eql 15
    calc.current.should eql 15

    subscribed = double(:count => 15 + 2)
    User.stub(:subscribed_to) { subscribed }
    calc.update_count!
    calc.current.should eql 17

    subscribed = double(:count => 15 + 2 + 235)
    User.stub(:subscribed_to) { subscribed }
    calc.update_count!
    calc.current.should eql 252
  end

  it "should never go back" do
    movement = FactoryGirl.create(:movement)
    calc = MemberCountCalculator.init(movement, 10)
    calc.current.should eql 10
    User.stub_chain(:subscribed_to, :count) { 0 }

    calc.update_count!
    calc.current.should eql 10
  end

  describe "#init" do
    it "should initialize the counter using the real members count as the default value" do
      User.stub_chain(:subscribed_to, :count) { 735 }
      movement = FactoryGirl.create(:movement)
      calc = MemberCountCalculator.init(movement)
      calc.current.should eql 735
    end

    it "should initialize the counter using a given value" do
      movement = FactoryGirl.create(:movement)
      calc = MemberCountCalculator.init(movement, 666)
      calc.current.should eql 666
    end
  end

  describe "#update_all_counts" do
    it "should update the count for all movements" do
      movements = []

      5.times { movements << FactoryGirl.create(:movement) }

      5.times do |i|
        user_double = double
        user_double.should_receive(:count).and_return(i*100)
        User.should_receive(:subscribed_to).with(movements[i]).and_return(user_double)
      end

      MemberCountCalculator.update_all_counts!
      MemberCountCalculator.for_movement(movements[0]).current.should == 0
      MemberCountCalculator.for_movement(movements[2]).current.should == 200
      MemberCountCalculator.for_movement(movements[4]).current.should == 400
    end
  end

  describe 'current and last member counts' do
    it "should return delimited current member count for a movement and locale" do
      movement = FactoryGirl.create(:movement)
      mcc = MemberCountCalculator.init(movement, 10000)
      mcc.update_attribute(:last_member_count, 11000)
      MemberCountCalculator.current_member_count(movement, :en).should == '10,000'
    end

    it "should return delimited last member count for a movement and locale" do
      movement = FactoryGirl.create(:movement)
      mcc = MemberCountCalculator.init(movement, 10000)
      mcc.update_attribute(:last_member_count, 11000)
      MemberCountCalculator.last_member_count(movement, :en).should == '11,000'
    end
  end
end
