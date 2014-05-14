class Admin::FeaturedContentModulesController < Admin::AdminController
  before_filter :load_collection, except: [:destroy]

  def create
    content_modules = @collection.possible_languages.each_with_object({}) do |language, hash|
      content_module = FeaturedContentModule.new(featured_content_collection: @collection, language: language)
      content_module.populate_from_action_page(params[:action_page_id], language.id) if params[:action_page_id]
      content_module.save!(validate: false)
      hash[language.iso_code] = content_module
    end

    render content_type: 'text/html', partial: 'admin/featured_content_collections/featured_content_modules',
           locals: {featured_content_modules: content_modules, movement: @movement, collection: @collection}
  end

  def destroy
    FeaturedContentModule.find(params[:id]).destroy
    head :ok
  end

  def sort
    featured_content_module = @collection.featured_content_modules.where(id: params[:featured_content_module][:id]).first
    featured_content_module.move_to params[:featured_content_module][:new_position]
    head :ok
  end

  private

  def load_collection
    @collection = FeaturedContentCollection.find(params[:featured_content_collection_id])
  end

end
