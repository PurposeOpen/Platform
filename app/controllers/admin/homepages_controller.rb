class Admin::HomepagesController < Admin::AdminController
  layout 'movements'
  self.nav_category = :homepage

  def show
    redirect_to edit_admin_movement_homepages_path(@movement)
  end

  def edit
    @homepage_contents = @movement.homepage.build_content_for_all_languages
  end

  def update
    homepage = @movement.homepage
    homepage.homepage_contents = params[:homepage_content].map do |iso_code, homepage_attrs|
      language = Language.find_by_iso_code(iso_code)
      homepage.build_content(language).tap do |content|
        content.update_attributes homepage_attrs
      end
    end

    if homepage.homepage_contents.all?(&:valid?)
      @homepage_contents = homepage.homepage_contents
      redirect_to edit_admin_movement_homepages_path(@movement), notice: 'Homepages have been updated.'
    else
      render action: 'edit'
      flash[:error] = 'Problems saving homepages, please try again.'
    end
  end

  def create_preview
    draft = @movement.homepage.duplicate_for_preview(params)
    render text: preview_admin_movement_homepages_path(@movement, draft_homepage_id: draft.id)
  end

  def preview
    render layout: '_base'
  end
end
