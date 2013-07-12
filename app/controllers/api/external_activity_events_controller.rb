class Api::ExternalActivityEventsController < Api::BaseController
  skip_before_filter :set_locale

  USER_PARAMS = %w(email first_name last_name postcode mobile_number home_number street_address suburb state country_iso is_member)

  def create
    begin
      set_up_user 
      (render json: @user.errors.to_json, status: :unprocessable_entity and return) if @user.invalid?
      @user.take_external_action!(tracked_email)

      external_action = ExternalAction.find_or_create_by_unique_action_slug(unique_action_slug, external_action_attributes)
      (render json: external_action.errors.to_json, status: :unprocessable_entity and return) if external_action.invalid?

      params[:tags].each { |name| external_action.external_tags << ExternalTag.find_or_create_by_name_and_movement_id!(name, movement.id) } if params[:tags].present?

      event = ExternalActivityEvent.new(event_attributes.merge(:external_action_id => external_action.id))
      (render :json => event.errors.to_json, status: :unprocessable_entity and return) if event.invalid?
      event.save!

      render status: :created, nothing: true
    rescue => e
      render status: :internal_server_error, json: {error: e.class.name.underscore}
    end
  end


  private

  def set_up_user
    @user = movement.members.find_or_initialize_by_email(user_attributes)

    if @user.new_record?
      @user.source = params['source']
    else
      @user.attributes = user_attributes
    end
  end

  def unique_action_slug
    "#{movement.id}_#{params[:source]}_#{params[:action_slug]}"
  end

  def user_params
    params['user'].slice(*USER_PARAMS)
  end

  def user_attributes
    @user_attributes ||= user_params.merge({'movement_id' => movement.id,
                                            'language_id' => language_id(params['action_language_iso'])})
  end

  def external_action_params
    params.permit(:action_slug, :partner, :source, :action_language_iso)
  end

  def external_action_attributes
    external_action_params.merge(movement_id: movement.id)
  end

  def event_params
    params.permit(:role, :activity)
  end

  def event_attributes
    event_params.merge(user_id: @user.id)
  end

  def language_id(iso_code)
    language = Language.find_by_iso_code(iso_code) || movement.default_language
    language.id
  end

end
