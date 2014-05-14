# == Schema Information
#
# Table name: featured_content_collections
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  featurable_id   :integer
#  featurable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class FeaturedContentCollection < ActiveRecord::Base
	belongs_to :featurable, polymorphic: true
	has_many :featured_content_modules, order: "position", dependent: :destroy

  def contantized_name
    self.name.gsub(' ', '')
  end

  def possible_languages
    featurable.movement.languages
  end

  def modules_for_language(lang)
    language = [String, Symbol].include?(lang.class) ? Language.find_by_iso_code(lang) : lang
    featured_content_modules.where(language_id: language.id).all
  end

  def valid_modules_for_language(lang)
    modules_for_language(lang).select(&:valid_with_warnings?)
  end

  def all_modules_valid?(lang)
    modules_for_language(lang).all?(&:valid_with_warnings?)
  end
end
