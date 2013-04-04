class Admin::ImagesController < Admin::AdminController
  layout 'movements'
  self.nav_category = :images

  PAGE_SIZE = 30

  before_filter :recent_images, :only => [:create, :index]

  def index
    @new_image = Image.new
  end

  def show
    @image = Image.find(params[:id])
  end

  def create
    additional_parameters = {'image_resize' => params['image']['image_resize'] == '1',
                             'image_height' => params['image']['image_height'],
                             'image_width' => params['image']['image_width'],
                             'movement_id' => @movement.id}

    @new_image = Image.new(additional_parameters.merge(params[:image]))
    if @new_image.save
      render(:layout => false) and return if request.xhr?
      flash[:notice] = 'Image uploaded. It may take up to 60 seconds for it to show up in search results.'
      redirect_to admin_movement_image_path(@movement, @new_image)
    else
      request.xhr? ? render(:text => @new_image.errors.full_messages, :status => :bad_request) : render(:action => 'index')
    end
  end

  private

  def recent_images
    movement_id = @movement.id
    unless params[:query].blank?
      search = Image.search do
        keywords params[:query]
        with :movement_id, movement_id
        order_by :created_at, :desc
        paginate :per_page => PAGE_SIZE, :page => params[:page]
      end
      @images = search.results
    else
      @images = Image.where(:movement_id => movement_id).order('created_at DESC').
          paginate(:per_page => PAGE_SIZE, :page => params[:page])
    end
  end
end
