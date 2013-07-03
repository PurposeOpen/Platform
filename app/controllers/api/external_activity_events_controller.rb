class Api::ExternalActivityEventsController < Api::BaseController
  skip_before_filter :set_locale

  USER_PARAMS = %w(email first_name last_name postcode mobile_number home_number street_address suburb state country_iso is_member)

  def create
    begin
      @user = movement.members.find_or_initialize_by_email(user_attributes)

      if @user.new_record?
        @user.source = params['source']
      else
        @user.attributes = user_attributes
      end

      (render :json => @user.errors.to_json, :status => :unprocessable_entity and return) unless @user.valid?
      @user.take_external_action!(tracked_email)

      external_action = ExternalAction.find_or_create_by_unique_action_slug("#{params[:source]}_#{params[:action_slug]}")
      params[:tags].each { |name| external_action << ExternalTag.find_or_create_by_name(name) }

      event = ExternalActivityEvent.new(event_attributes)
      (render :json => event.errors.to_json, :status => :unprocessable_entity and return) unless event.valid?
      event.save!

      render :status => :created, :nothing => true
    rescue => e
      raise e.inspect
      render :status => :internal_server_error, :json => {:error => e.class.name.underscore}
    end
  end


  private

  def user_params
    params['user'].slice(*USER_PARAMS)
  end

  def user_attributes
    @user_attributes ||= user_params.merge({'movement_id' => movement.id,
                                            'language_id' => language_id(params['action_language_iso'])})
  end

  def event_params
    params.permit(:source, :partner, :action_slug, :action_language_iso, :role, :activity)
  end

  def event_attributes
    event_params.merge(:movement_id => movement.id, :user_id => @user.id)
  end

  def language_id(iso_code)
    language = Language.find_by_iso_code(iso_code) || movement.default_language
    language.id
  end

end
