module Admin
  class MovementsController < AdminController
    layout 'movements', except: [:new]
    self.nav_category = :home

    PAGE_SIZE = 5

    crud_actions_for Movement, redirects: {
        update: lambda { admin_movement_path(@movement) },
    }

    authorize_resource :movement, only: [:show]

    def new
      authorize! :new, Movement
      @movement = Movement.new
    end

    def create
      languages = extract_languages(params[:movement])
      default_language = extract_default_language(params[:movement])
      @movement = Movement.new(params[:movement])
      @movement.languages = languages if languages
      authorize! :create, @movement

      if @movement.save
        @movement.default_language = default_language if default_language
        redirect_to admin_movement_path(@movement), notice: "'#{@movement.name}' has been created."
      else
        flash[:error] = 'Your changes have NOT BEEN SAVED YET. Please fix the errors below.'
        render action: 'new'
      end
    end

    def edit
      @nav_category = :settings
      @movement = Movement.find(params[:id])
      authorize! :edit, @movement
    end

    def update
      @movement = Movement.find(params[:id])
      languages = extract_languages(params[:movement])
      @movement.languages = languages if languages
      authorize! :update, model
      if @movement.update_attributes(params[model_name])
        redirect_to admin_movement_path(@movement), notice: "'#{@movement.name}' has been updated."
      else
        flash[:error] = 'Your changes have NOT BEEN SAVED YET. Please fix the errors below.'
        render action: 'edit'
      end
    end

    def extract_default_language(movement_attrs)
      unless movement_attrs.blank? || movement_attrs[:default_language].blank?
        default_language = movement_attrs.delete(:default_language)
        Language.find(default_language)
      end
    end

    def show
      options = {per_page: PAGE_SIZE,
                 page: params[:page],
                 order: 'created_at DESC',
                 conditions: {movement_id: @movement.id}}
      @campaigns = Campaign.paginate(options)
    end

    def index
      redirect_to admin_movement_path(current_platform_user.primary_movement)
    end

    private

    def extract_languages(movement_attrs)
      unless movement_attrs.blank? || movement_attrs[:languages].blank?
        language_ids = movement_attrs.delete(:languages)
        Language.find(language_ids)
      end
    end
  end
end
