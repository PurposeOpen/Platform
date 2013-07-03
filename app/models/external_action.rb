class ExternalAction < ActiveRecord::Base
  attr_accessible :action_language_iso, :action_slug, :movement_id, :partner, :source, :unique_action_slug
end
