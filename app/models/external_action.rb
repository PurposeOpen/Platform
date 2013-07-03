class ExternalAction < ActiveRecord::Base
  attr_accessible :action_language_iso, :action_slug, :movement_id, :partner, :source, :unique_action_slug
  validates :action_language_iso, :action_slug, :movement_id, :source, :unique_action_slug, presence: true
  validates :unique_action_slug, uniqueness: true
  has_and_belongs_to_many :external_tags, uniq: true
end
