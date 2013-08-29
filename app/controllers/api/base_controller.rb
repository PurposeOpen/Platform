class Api::BaseController < ApplicationController
  before_filter :load_movement, :authenticate, :set_locale, :log_original_request_uuid
  #before_filter :debug_headers
  skip_before_filter :verify_authenticity_token

  private

  def identify_email
    @email = email_tracking_hash.email
  end
  
  def log_original_request_uuid
    logger.info "X-ORIGINAL-REQUEST-UUID: #{request.env['HTTP_X_ORIGINAL_REQUEST_UUID']}"
    logger.info "X-ORIGINAL-REQUEST-IP: #{request.env['HTTP_X_ORIGINAL_REQUEST_IP']}"
  end
  
  def debug_headers
    if Rails.logger.level == 0 #:debug  
      logger.debug "*** BEGIN RAW REQUEST HEADERS ***"
      self.request.env.each do |header|
        logger.debug "#{header[0]}: #{header[1]}"
      end
      logger.debug "*** END RAW REQUEST HEADERS ***"      
    end
  end

  def movement    
    unless @movement.present?
      @movement=Movement.find(params[:movement_id])
      logger.debug "Movement set to #{@movement.inspect}"
    end
    
    @movement
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
    I18n.locale = identify_accepted_language ||  movement.default_iso_code  || "en"
    logger.debug "I18n.locale set to #{I18n.locale}"
    headers["Content-Language"] = I18n.locale.to_s
  end

  def identify_accepted_language
    language_headers = request.env['HTTP_ACCEPT_LANGUAGE'] || ''
    logger.debug "HTTP_ACCEPT_LANGUAGE is #{language_headers.inspect}"
    languages_iso_codes = movement.languages.pluck("languages.iso_code")
    accepted_language = language_headers.split(',').select { |language| languages_iso_codes.include? language }.first
    logger.debug "Accepted Language is #{accepted_language}"
    if accepted_language.blank? && languages_iso_codes.include?(params[:locale])
      accepted_language = params[:locale]
    end

    accepted_language
  end

end