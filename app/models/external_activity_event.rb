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
#

class ExternalActivityEvent < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :action_slug, :action_language_iso, :partner, :role, :source, :user_id, :movement_id

  validates_presence_of :action_slug, :action_language_iso, :role, :source, :user_id, :movement_id


end
