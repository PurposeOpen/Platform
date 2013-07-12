# == Schema Information
#
# Table name: external_actions
#
#  id                  :integer          not null, primary key
#  movement_id         :integer          not null
#  source              :string(255)      not null
#  partner             :string(255)
#  action_slug         :string(255)      not null
#  unique_action_slug  :string(255)      not null
#  action_language_iso :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class ExternalAction < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :action_language_iso, :action_slug, :movement_id, :partner, :source, :unique_action_slug

  has_and_belongs_to_many :external_tags, uniq: true
  belongs_to :movement

  before_validation :ensure_unique_action_slug_is_present

  validates_presence_of :movement_id, :source, :action_slug, :unique_action_slug, :action_language_iso
  validates_uniqueness_of :unique_action_slug

  private

  def ensure_unique_action_slug_is_present
    if self.unique_action_slug.blank?
      self.unique_action_slug = "#{self.movement_id}_#{self.source}_#{self.action_slug}"
    end
  end

end
