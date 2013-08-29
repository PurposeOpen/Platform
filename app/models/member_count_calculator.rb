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

class MemberCountCalculator < ActiveRecord::Base
  FACTOR = 1
  extend ActionView::Helpers::NumberHelper

  validates_uniqueness_of :movement_id

  belongs_to :movement

  scope :scoped_to_movement, (proc do |a_movement|
    where(:movement_id => a_movement.id)
  end)

  def self.for_movement(a_movement)
    scoped_to_movement(a_movement).first
  end

  def self.init(a_movement,val=nil)
    val = User.subscribed_to(a_movement).count if val.nil?
    calc = for_movement(a_movement)
    calc.nil? ? create(:current => val, :last_member_count => val, :movement => a_movement) : calc.tap{calc.update_attributes(:current => val, :last_member_count => val)}
  end

  def self.update_all_counts!
    all.each do |count|
      count.update_count!
    end
  end

  def self.init_all_counts!
    Movement.all.each do | a_movement |
      MemberCountCalculator.init(a_movement)
    end
  end

  def update_count!
    real_member_count = User.subscribed_to(movement).count
    growth = (real_member_count - last_member_count)/FACTOR
    update_attributes(:current => current + growth, :last_member_count => real_member_count) if growth > 0
    current
  end

  def self.current_member_count(movement, locale)
    count_for(:current, movement, locale)
  end

  def self.last_member_count(movement, locale)
    count_for(:last_member_count, movement, locale)
  end

  def self.count_for(kind, movement, locale)
    number_with_delimiter(for_movement(movement).send(kind), :locale => locale)
  end
end
