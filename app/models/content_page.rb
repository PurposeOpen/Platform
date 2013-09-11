# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  action_sequence_id         :integer
#  name                       :string(64)
#  created_at                 :datetime
#  updated_at                 :datetime
#  deleted_at                 :datetime
#  position                   :integer
#  required_user_details      :text
#  views                      :integer          default(0), not null
#  created_by                 :string(255)
#  updated_by                 :string(255)
#  alternate_key              :integer
#  paginate_main_content      :boolean          default(FALSE)
#  no_wrapper                 :boolean
#  type                       :string(255)
#  content_page_collection_id :integer
#  movement_id                :integer
#  slug                       :string(255)
#  live_page_id               :integer
#  crowdring_campaign_name    :string(255)
#

class ContentPage < Page
  include QuickGoable
  belongs_to :content_page_collection
  has_many :featured_content_collections, as: :featurable, dependent: :destroy

  def as_json(opts={})
    language = language_option(opts)
    json = {}
    json[:featured_contents] = {}
    featured_content_collections.each {|collection|
      json[:featured_contents][collection.contantized_name] = collection.valid_modules_for_language(language).sort_by(&:position)
    }

    json.merge super
  end

  def initialize_defaults!
    self.views = 0
    self.name = copy_attribute_with_next_version(:name)
  end
end
