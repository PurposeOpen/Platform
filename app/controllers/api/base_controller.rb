class Api::BaseController < ApplicationController
  before_filter :load_movement, :authenticate, :set_locale
  skip_before_filter :verify_authenticity_token

  private

  def tracked_email
    @email = email_tracking_hash.email
  end

  def movement
    @movement ||= Movement.find(params[:movement_id])
  end

  def load_movement
    movement
  rescue ActiveRecord::RecordNotFound
    render :status => 404, :text => "Can't find movement with ID #{params[:movement_id]}"
  end

  def should_authenticate?
    AppConstants.authenticate_api_calls.to_s == 'true'
  end

  def api_call_authenticated?
    authenticate_with_http_basic {|u, p| movement.authenticate(p) }
  end

  def authenticate
    if should_authenticate? && !api_call_authenticated?
      render text: 'Not authorized', status: 401
    end
  end

  def set_locale
    I18n.locale = identify_accepted_language || movement.default_iso_code || 'en'
    headers['Content-Language'] = I18n.locale.to_s
  end

  def identify_accepted_language
    languages_iso_codes = movement.languages.pluck('languages.iso_code')
    languages_iso_codes.include?(params[:locale]) ? params[:locale] : nil
  end

end