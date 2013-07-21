class Admin::ContentModulesController < Admin::AdminController
  before_filter :load_page

  def load_page
    @movement = Movement.find(params[:movement_id])
    @page = @movement.find_page(params[:page_id])
  end
  private :load_page

  def create
    content_modules = []
    @page.possible_languages.each do |language|
      content_module = params[:type].constantize.new
      content_module.language = language
      content_module.save!(:validate => false)

      content_modules << content_module
      @page.content_module_links.create!(:layout_container => params[:container], :content_module => content_module)
    end
    render :content_type => 'text/html', :partial => 'admin/content_modules/content_modules', :locals => {:content_modules => content_modules, :movement => @movement, :page => @page}
  end

  def create_links_to_existing_modules
    target_page = params[:target_page_type].classify.constantize.find(params[:target_page_id])
    new_content_modules = @page.link_existing_modules_to(target_page, params[:container])
    
    render :content_type => 'text/html', :partial => 'admin/content_modules/content_modules', :locals => {
      :content_modules => new_content_modules,
      :movement => @movement,
      :page => target_page
    }
  end

  def delete
    content_module = ContentModuleLink.where(:page_id => @page.id, :content_module_id => params[:content_module_id]).first
    if content_module
      content_module.destroy
      head :ok
    else
      head 404
    end
  end

  def sort
    content_module_link = @page.content_module_links.where(
        :content_module_id => params[:content_module][:content_module_id]
    ).first

    content_module_link.move_to_container params[:content_module][:new_container], params[:content_module][:new_position]
    head :ok
  end
end