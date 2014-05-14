class Admin::FeaturedContentCollectionsController < Admin::AdminController
  layout 'movements'
  self.nav_category = :featured_content_collections

  before_filter :load_featured_content_collection, only: [:edit, :update]

  def index
    featured_content_collections = FeaturedContentCollection.includes(:featurable).select do |collection|
      (collection.featurable.movement_id == @movement.id) && (collection.featurable.respond_to?(:draft?) ? !collection.featurable.draft? : true)
    end
    @featured_pages = featured_content_collections.group_by &:featurable
  end

  def edit
  end

  def update
    success = true
    params[:featured_content_modules].each do |id, attrs|
      content_module = FeaturedContentModule.find(id)
      success = content_module.update_attributes(attrs) && success
    end

    if success
      flash[:notice] = ('Featured content updated.')
      redirect_to action: 'edit'
    else
      flash.now[:info] = ('Error updating featured content modules. Title, Url, and Button text are required for all modules across all languages.')
      render :edit
    end
  end

  private

  def load_featured_content_collection
    @featured_content_collection = FeaturedContentCollection.find(params[:id], include: :featured_content_modules)
  end
end
