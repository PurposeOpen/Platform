class Admin::ContentPagesController < Admin::AdminController
  include ActionView::Helpers::TextHelper

  layout 'movements'
  self.nav_category = :content_pages
  skip_authorize_resource # We have no static page model, which confuses CanCan.
  skip_authorization_check # Anyone with access to the admin interface can see the static pages index page.

  crud_actions_for ContentPage, :redirects => {
      :destroy => lambda { admin_movement_content_pages_path(@movement) }
  }

  before_filter -> {@content_page = @movement.find_page(params[:id])}, only: [:create_preview]
  before_filter -> {@content_page = @movement.find_page_unscoped(params[:id])}, only: [:preview, :save_preview]

  skip_before_filter  :find_model, only: [:preview, :save_preview]
  skip_before_filter  :find_parent, only: [:preview, :save_preview]

  def index
    @content_page_collections = @movement.content_page_collections
    @content_page_collections.each { |collection| collection.content_pages.sort_by!(&:name) }
  end

  def new
    content_page_collection_id = params['content_page_collection_id']
    @content_page = ContentPage.new(:content_page_collection_id => content_page_collection_id)
  end

  def edit
    @content_page = @movement.find_page(params[:id])
  end

  def create
    content_page_attributes = params[:content_page].merge(:content_page_collection_id => params[:content_page_collection_id])
    @content_page = @movement.content_pages.create(content_page_attributes)
    redirect_to edit_admin_movement_content_page_path(@movement, @content_page)
  end

  def update
    @content_page = @movement.find_page(params[:id])
    all_modules = @content_page.header_content_modules + @content_page.sidebar_content_modules + @content_page.main_content_modules+ @content_page.footer_content_modules

    page_updated = @content_page.update_attributes(params[:content_page])
    content_updated = update_content_modules(params[:content_modules], all_modules)

    if page_updated && content_updated
      flash[:notice] = "'#{@content_page.name}' has been updated."
    else
      flash.now[:info] = 'Content module(s) not saved due to content errors.'
    end

    redirect_to edit_admin_movement_content_page_path(@movement, @content_page)
  end

  def create_preview
    cloned_content_page = @content_page.dup
    cloned_content_page.live_page_id = @content_page.id
    cloned_content_page.save
    all_modules = @content_page.header_content_modules + @content_page.sidebar_content_modules + @content_page.main_content_modules + @content_page.footer_content_modules
    clone_content_modules_for_preview(params[:content_modules], all_modules, cloned_content_page)
    cloned_content_page.update_attributes(params[:content_page])
    render :text => preview_admin_movement_content_page_path(@movement, cloned_content_page), :status => :ok
  end

  def preview
    @movement = Movement.find(params[:movement_id])
    @content_page = @movement.find_page_unscoped(params[:id])
    render :layout => '_base'
  end

  private

  def update_content_modules(updated_attrs, content_modules)
    # Rick, 2010-01-25: We would ideally use Page#accepts_nested_attributes_for :content_modules here.
    # An apparent bug in activerecord's has_many :through associations returns different instances across
    # multiple calls to @page.content_modules.
    # Possibly related to https://rails.lighthouseapp.com/projects/8994/tickets/4642
    return true unless updated_attrs
    success = true
    updated_attrs.each do |id, attrs|
      content_module = content_modules.find { |cm| cm.id == id.to_i }
      success = content_module.update_attributes(attrs) && success
    end
    success
  end

  def clone_content_modules_for_preview(updated_attributes, content_modules, cloned_content_page)
    return true unless updated_attributes
    success = true
    updated_attributes.each do |id, attrs|
      content_module = content_modules.find { |cm| cm.id == id.to_i }
      moduleLinks = ContentModuleLink.where(:page_id => @content_page.id, :content_module_id => content_module.id)
      cloned_content_module = content_module.dup
      cloned_content_module.live_content_module_id = content_module.id
      cloned_content_module.update_attributes(attrs)
      moduleLinks.each do |cml|
        cloned_cml = cml.dup
        cloned_cml.page_id = cloned_content_page.id
        cloned_cml.content_module = cloned_content_module
        cloned_cml.save
      end
    end
    success
  end
end