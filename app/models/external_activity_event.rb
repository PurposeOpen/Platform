# == Schema Information
#
# Table name: external_activity_events
#
#  id                 :integer          not null, primary key
#  role               :string(255)
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  activity           :string(255)
#  external_action_id :integer
#

class ExternalActivityEvent < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :role, :user_id, :activity, :external_action_id

  belongs_to :user
  belongs_to :external_action

  module Activity
    ACTION_TAKEN = 'action_taken'
    ACTION_CREATED = 'action_created'
  end

  ACTIVITIES = [Activity::ACTION_TAKEN, Activity::ACTION_CREATED]

  validates_presence_of   :role, :user_id, :external_action_id
  validates_inclusion_of  :activity,    :in => ACTIVITIES


  after_create :consider_creators_supporters_of_their_action
  after_commit ->{Rails.cache.delete("/grouped_select_options_external_actions/#{movement_id}")}

  private

  def consider_creators_supporters_of_their_action
    if self.activity == Activity::ACTION_CREATED
      attributes = self.attributes.slice(*self.class.accessible_attributes).merge('activity' => Activity::ACTION_TAKEN)

      self.class.create!(attributes)
    end

    return true
  end

end
