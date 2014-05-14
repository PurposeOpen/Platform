# == Schema Information
#
# Table name: featured_content_modules
#
#  id                             :integer          not null, primary key
#  featured_content_collection_id :integer
#  language_id                    :integer
#  title                          :text
#  image                          :string(255)
#  description                    :text
#  url                            :string(255)
#  button_text                    :string(255)
#  date                           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  position                       :integer
#

class FeaturedContentModule < ActiveRecord::Base
	belongs_to :featured_content_collection
	belongs_to :language
  acts_as_list scope: 'featured_content_collection_id=#{featured_content_collection_id} and language_id=#{language_id}'

  warnings do
    validates_presence_of :title, :url, :button_text
  end

  def move_to(new_position)
    remove_from_list
    insert_at new_position
  end

  def populate_from_action_page(action_page_id, language_id)
    action_page = ActionPage.find(action_page_id)
    language = Language.find(language_id)
    header_content_module = action_page.header_content_modules_for_language(language_id).first
    sidebar_content_module = action_page.sidebar_content_modules_for_language(language_id).first

    self.title = header_content_module.try(:content)
    self.description = sidebar_content_module.try(:content)
    self.url = "/#{language.iso_code}/actions/#{action_page.slug}"
    self.button_text = sidebar_content_module.try(:button_text)
  end

end
