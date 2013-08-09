class Api::MovementsController < Api::BaseController
  include InlineTokenReplacement
  #before_filter :homepage_content, :only => [:show]

  caches_action :show, :expires_in => AppConstants.default_cache_timeout, :race_condition_ttl => 30.seconds, :cache_path => Proc.new {|c| "#{I18n.locale}#{c.request.path}" }
  cache_sweeper Api::MovementSweeper

  def show
    homepage = params[:draft_homepage_id].blank? ? movement.homepage : movement.draft_homepages.where(:id => params[:draft_homepage_id]).first
    @homepage_content = Rails.cache.fetch('homepage_content/movement/#{movement.id}/locale/#{I18n.locale}/homepage/#{homepage.id}', expires_in: 24.hours) do
      build_homepage_content(homepage) 
    end
    @featured_content_collections = Rails.cache.fetch('featured_content_collections/movement/#{movement.id}/locale/#{I18n.locale}/homepage/#{homepage.id}', expires_in: 24.hours) do
      build_featured_content_collections(homepage)
    end
    lang_cache_key = '/languages/movement_id/#{movement.id}'
    languages = Rails.cache.fetch(lang_cache_key, expires_in: 24.hours) do
      languages = movement.languages.map do |lang|
        {:iso_code => lang.iso_code, :name => lang.name, :native_name => lang.native_name, :is_default => (lang == movement.default_language)}
      end
      languages
    end

    track_page_view_from_email

    render :json => {
        languages: languages,
        recommended_languages_to_display: languages_to_display,
        banner_text: replace_banner_text_tokens(I18n.locale),
        featured_contents: @featured_content_collections
    }.merge(homepage_attributes)
  end

  protected

  def build_homepage_content(homepage)
    @homepage_content ||= homepage.homepage_contents.by_iso_code(I18n.locale).first
  end

  def build_featured_content_collections(homepage)
    featured_content_collections = {}
    homepage.featured_content_collections.each do |fcc|
      featured_content_collections[fcc.contantized_name] = fcc.valid_modules_for_language(I18n.locale).sort_by(&:position)
    end
    featured_content_collections
  end

  def homepage_attributes
    @homepage_content ? @homepage_content.attributes.slice('banner_image', 'join_headline', 'join_message', 'follow_links', 'footer_navbar', 'header_navbar') : {}
  end

  def replace_banner_text_tokens(locale)
    banner_text = @homepage_content ? @homepage_content['banner_text'] : ''
    replace_tokens(banner_text, 'MEMBERCOUNT' => lambda { |default| "<span class='member_count'>#{MemberCountCalculator.current_member_count(movement, params[:id])}</span>" })
  end

  #email tracking should be removed from here when all movements have been changed to use email_tracking_controller#email_clicked
  def track_page_view_from_email
    if user_visited_from_email?
      page = find_clicked_page
      page.register_click_from email_tracking_hash.email, email_tracking_hash.user
    end
  end

  def user_visited_from_email?
    params[:t].present?
  end

  def find_clicked_page
    params[:page_type] == 'Homepage' ? movement.homepage : movement.find_page(params[:page_id])
  end

  private
  def languages_to_display
    languages_which_can_be_shown = []
    movement.languages.each do |language|
      homepage_content_for_language = movement.homepage.build_content(language)
      languages_which_can_be_shown << language if homepage_content_for_language.content_complete?
    end
    languages_which_can_be_shown = languages_which_can_be_shown.map do |lang|
      {:iso_code => lang.iso_code, :name => lang.name, :native_name => lang.native_name, :is_default => (lang == movement.default_language)}
    end
    languages_which_can_be_shown
  end
end
