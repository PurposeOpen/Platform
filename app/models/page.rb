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

class Page < ActiveRecord::Base
  extend FriendlyId
  include ActsAsClickableFromEmail
  acts_as_user_stampable
  acts_as_paranoid

  has_many :content_module_links
  has_many :content_modules, through: :content_module_links, dependent: :delete_all

  friendly_id :name, use: :scoped, scope: :movement_id
  before_validation :update_movement_id_column
  validates_presence_of :movement_id

  validates_length_of :name, maximum: 64, minimum: 3
  validate :unique_slug_within_movement

  default_scope where(live_page_id: nil)
  scope :for_preview, ->(movement_id){ where(deleted_at: nil, movement_id: movement_id) }

  belongs_to :movement

  class << self
    def clean_preview_pages!
      ContentModule.connection.execute("delete from content_modules where live_content_module_id is not null")
      ContentModuleLink.connection.execute("delete from content_module_links where page_id in (select id from pages where live_page_id is not null)")
      AutofireEmail.connection.execute("delete from autofire_emails where action_page_id in (select id from pages where live_page_id is not null)")
      Page.connection.execute("delete from pages where live_page_id is not null")
    end
  end

  def possible_languages
    movement.languages
  end

  def modules_for_container_and_language(container, language)
    if module_links_by_language(language).empty? && !modules_should_all_be_empty?
      generate_modules_for_new_language(language)
    end

    ContentModule.all(:include => [:content_module_links, :language],
                      conditions: "languages.iso_code = '#{language.iso_code}' and
                                      content_module_links.page_id = #{self.id} and content_module_links.layout_container='#{container}'",
                      order: 'content_module_links.position')
  end

  def all_modules_valid?(language)
    valid = module_links_by_language(language).collect(&:content_module).all?(&:valid_with_warnings?)
    valid = autofire_email_for_language(language).valid_with_warnings? if (valid && should_have_autofire_emails?)
    valid
  end

  def generate_modules_for_new_language(new_language)
    default_language_module_links.map do |old_module_link|
      old_module = old_module_link.content_module
      new_module = old_module.class.new(:language => new_language)
      new_module.save! validate: false

      new_module_link = self.content_module_links.create!(
        position: old_module_link.position,
        layout_container: old_module_link.layout_container,
        content_module: new_module
      )

      new_module
    end
  end

  def header_content_modules
    @header_content_modules ||= find_modules_for_container(:header_content)
  end

  def main_content_modules
    @main_content_modules ||= find_modules_for_container(:main_content)
  end

  def sidebar_content_modules
    @sidebar_content_modules ||= find_modules_for_container(:sidebar)
  end

  def footer_content_modules
    @footer_content_modules ||= find_modules_for_container(:footer)
  end

  def header_content_modules_for_language(language_id)
    header_content_modules.select { |header_content_module| header_content_module.language_id == language_id }
  end

  def sidebar_content_modules_for_language(language_id)
    sidebar_content_modules.select { |sidebar_content_module| sidebar_content_module.language_id == language_id }
  end

  def valid_main_content_modules
    main_content_modules.select(&:valid?)
  end

  def valid_header_content_modules
    header_content_modules.select(&:valid?)
  end

  def should_have_autofire_emails?
    false
  end

  def url_for_language(language)
    [ movement.url, language.iso_code, self.slug ].join('/')
  end

  def default_url
    [ movement.url, self.slug ].join('/')
  end

  def as_json(opts={})
    language = language_option(opts)
    {
      id: id,
      name: name,
      type: type,
      header_content_modules: modules_as_json(modules_for_container_and_language(ContentModule::HEADER, language), opts),
      main_content_modules: modules_as_json(modules_for_container_and_language(ContentModule::MAIN, language), opts),
      sidebar_content_modules: modules_as_json(modules_for_container_and_language(ContentModule::SIDEBAR, language), opts),
      footer_content_modules: modules_as_json(modules_for_container_and_language(ContentModule::FOOTER, language), opts)
    }
  end

  def language_option(opts)
    language = opts[:language] || movement.default_language
    language.is_a?(String)? Language.find_by_iso_code(language) : language
  end

  protected :language_option


  private


  def update_movement_id_column
    self.movement_id = movement.try(:id)
  end

  def modules_should_all_be_empty?
    default_language_module_links.empty?
  end

  def default_language_module_links
    @default_language_module_links ||= module_links_by_language(self.movement.default_language)
  end

  def module_links_by_language(language)
    ContentModuleLink.where(
      page_id: self.id,
        languages: {
          iso_code: language.iso_code
        }
    ).joins(:content_module => :language)
  end

  def unique_slug_within_movement
    page_slug = self.normalize_friendly_id(self.name.try(:parameterize))
    return if page_slug.nil? || movement.nil? || !self.live_page_id.nil?
    unique_slug_scope = movement.pages.where(slug: page_slug)
    unique_slug_scope = unique_slug_scope.where("id <> ?", self.id) if persisted?
    self.errors.add(:name, "must be unique within movement.") if unique_slug_scope.exists?
  end

  def find_modules_for_container(container)
    content_module_links.includes(:content_module).where(:layout_container => container).order(:position).map(&:content_module)
  end

  def modules_as_json(modules, opts)
    modules.map do |m|
      m.as_json(opts)
    end
  end
end
