# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

class ContentModule < ActiveRecord::Base
  include InlineTokenReplacement
  include CountryHelper
  include SerializedOptions

  HEADER  = :header_content
  MAIN    = :main_content
  SIDEBAR = :sidebar
  FOOTER  = :footer

  ALL_CONTAINERS = [ HEADER, MAIN, SIDEBAR ]

  has_many :content_module_links
  has_many :pages, :through => :content_module_links
  has_many :user_activity_events
  belongs_to :language

  validates_presence_of :language_id

  warnings do
    validates_length_of :title, :maximum => 128, :minimum => 3, :if => :needs_title?
    validates_length_of :public_activity_stream_template, :maximum => 1024, :minimum => 3, :if => :shows_activity_stream?
  end

  before_save :tidy_html

  class_attribute :valid_containers

  def as_json(options = {})
    super.merge type: type
  end

  def valid_containers; self.class.valid_containers; end

  class << self
    def placeable_in(*containers)
      self.valid_containers = containers.flatten
    end

    def for_container?(container)
      self.valid_containers.include?(container)
    end

    def label
      name.titleize
    end
  end

  def is_ask?
    self.respond_to?(:take_action)
  end

  def subscribes_user_on_action?
    self.is_ask?
  end

  def linked?
    @is_linked ||= ContentModuleLink.where(:content_module_id => self.id).count > 1
  end

  def public_activity_stream_html(user, page, language = nil)
    return nil unless is_ask?

    if language.nil?
      content_module = page.ask_module
    else
      content_module = page.ask_module_for_language(language)
    end

    # This is mostly for backwards compatibility.
    content_module ||= self
    html = replace_tokens(content_module.public_activity_stream_template,
      "NAME" => lambda { |default| "<span class=\"name\">#{user.greeting || default}</span>" },
      "COUNTRY" => user.country_iso ? country_name(user.country_iso, language.try(:iso_code)).titleize : '',
      "HEADER" =>  replacement_for_header_token(page, language)
    )
    html.gsub /\[(.*)\]/, %{<a data-action-name="#{page.action_sequence.friendly_id}" data-page-name="#{page.action_sequence.action_pages.first.friendly_id}">\\1</a>}
  end

  def first_image
    needle = Nokogiri::HTML::DocumentFragment.parse(self.content).css("img")
    if needle && needle.size > 0
      needle.first["src"]
    else
      false
    end
  end

  def needs_title?
    is_ask?
  end

  def shows_activity_stream?
    is_ask?
  end

  def can_remove_from_page?
    true
  end

  def requires_user_details?
    is_ask?
  end

  def autofire_tokens
    raise "Only ask modules may provide tokens for autofire emails" unless is_ask?
    {}
  end

  def default_autofire_sender
    AutofireEmail::DEFAULT_SENDER
  end

  def default_autofire_subject(movement)
    AutofireEmail.translated_defaults_map(movement)[language.iso_code][self.class.name.underscore][:subject]
  end

  def default_autofire_body(movement)
    AutofireEmail.translated_defaults_map(movement)[language.iso_code][self.class.name.underscore][:body]
  end

  private

  def tidy_html
    self.content = Nokogiri::HTML::DocumentFragment.parse(self.content).to_html
  end

  def replacement_for_header_token(page, language)
    language =  page.movement.default_language if language.nil?
    header_content_modules = page.modules_for_container_and_language(ContentModule::HEADER, language)
    return ActionView::Base.full_sanitizer.sanitize(header_content_modules.first.content) if header_content_modules.size > 0
    return ""
  end
end
