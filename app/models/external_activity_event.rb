# == Schema Information
#
# Table name: external_activity_events
#
#  id                  :integer          not null, primary key
#  source              :string(255)
#  movement_id         :integer
#  partner             :string(255)
#  action_slug         :string(255)
#  action_language_iso :string(2)
#  role                :string(255)
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  activity            :string(255)
#

class ExternalActivityEvent < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :movement
  belongs_to :user

  attr_accessible :action_slug, :action_language_iso, :partner, :role, :source, :user_id, :movement_id, :activity

  module Activity
    ACTION_TAKEN = 'action_taken'
    ACTION_CREATED = 'action_created'
  end

  ACTIVITIES = [Activity::ACTION_TAKEN, Activity::ACTION_CREATED]

  validates_presence_of :action_slug, :action_language_iso, :role, :source, :user_id, :movement_id
  validates_inclusion_of :activity, :in => ACTIVITIES


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
