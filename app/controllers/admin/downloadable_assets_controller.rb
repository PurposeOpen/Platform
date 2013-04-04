class Admin::DownloadableAssetsController < Admin::AdminController
  layout 'movements'
  PAGE_SIZE = 30
  layout 'movements'
  self.nav_category = :assets

  before_filter :recent_assets, :only => [:create, :index]

  def index
    @asset = DownloadableAsset.new
  end

  def show
    @asset = DownloadableAsset.find(params[:id])
  end

  def create
    additional_parameters = {'movement_id' => @movement.id}
    @asset = DownloadableAsset.new(additional_parameters.merge(params[:asset]))

    if @asset.save
      flash[:notice] = 'File uploaded. It may take up to 60 seconds for it to show up in search results.'
      redirect_to admin_movement_downloadable_asset_path(@movement, @asset)
    else
      render :action => 'index'
    end
  end

  private

  def recent_assets
    movement_id = @movement.id
    unless params[:query].blank?
      search = DownloadableAsset.search do
        keywords params[:query]
        with :movement_id, movement_id
        order_by :created_at, :desc
        paginate :per_page => PAGE_SIZE, :page => params[:page]
      end
      @assets = search.results
    else
      @assets = DownloadableAsset.where(:movement_id => movement_id).order('created_at DESC').
          paginate(:per_page => PAGE_SIZE, :page => params[:page])
    end
  end
end
