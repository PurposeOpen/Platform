class Api::ContentPagesController < Api::BaseController

  def show
    page = movement.find_page(params[:id])
    language = Language.find_by_iso_code(I18n.locale)
    render json: page.as_json(language: language)
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Can't find page with id #{params[:id]}"
  end

  def preview
    page = movement.find_page_unscoped(params[:id])
    language = Language.find_by_iso_code(I18n.locale)
    render json: page.as_json(language: language)
  rescue ActiveRecord::RecordNotFound
    render status: 404, text: "Can't find page with id #{params[:id]}"
  end
end