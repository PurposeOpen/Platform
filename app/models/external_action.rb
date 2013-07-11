class ExternalAction < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :action_language_iso, :action_slug, :movement_id, :partner, :source, :unique_action_slug

  validates_presence_of :action_language_iso, :action_slug, :movement_id, :source, :unique_action_slug
  validates_uniqueness_of :unique_action_slug

  has_and_belongs_to_many :external_tags, uniq: true
  belongs_to :movement
end
