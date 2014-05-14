# == Schema Information
#
# Table name: homepages
#
#  id          :integer          not null, primary key
#  movement_id :integer
#  draft       :boolean          default(FALSE)
#

class Homepage < ActiveRecord::Base
  include ActsAsClickableFromEmail

  belongs_to :movement
  has_many :homepage_contents, dependent: :destroy
  has_many :featured_content_collections, as: :featurable, dependent: :destroy
  has_many :featured_content_modules, through: :featured_content_collections

  class << self
    def clean_drafts!
      Homepage.where(draft: true).find_in_batches {|grp| grp.each{|homepage| homepage.destroy}}
    end
  end

  def duplicate_for_preview(attrs = {})
    config = {include: [:homepage_contents, {featured_content_collections: [:featured_content_modules]}]}
    self.dup(config) do |original, clone|
      clone.assign_attributes(attrs[:homepage_content][clone.iso_code]) if clone.is_a?(HomepageContent) && attrs[:homepage_content]
      clone.assign_attributes(attrs[:featured_content_modules][original.id]) if clone.is_a?(FeaturedContentModule) && attrs[:featured_content_modules]
    end.tap{|cloned_homepage| cloned_homepage.update_attributes(draft: true)}
  end

  def build_content_for_all_languages
    movement.languages.collect { |l| build_content(l) }
  end

  def build_content(language)
    homepage_contents.find_or_initialize_by_language_id(language.id)
  end

  def name
    'Homepage'
  end
end
