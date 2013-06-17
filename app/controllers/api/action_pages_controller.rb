class Api::ActionPagesController < Api::BaseController
  include CountryHelper

  def show
    page = movement.find_published_page(params[:id])
    language = Language.find_by_iso_code(I18n.locale)
    if page.language_enabled? language
      render :json => merge_join_and_member_count_attrs(page.as_json(language: language, email: params[:email], member_has_joined: params[:member_has_joined]), page)
    else
      render :status => :not_acceptable, :json => {:error => 'No content for content locale accepted by the client.'}
    end
  rescue ActiveRecord::RecordNotFound
    render :status => :not_found, :text => "Can't find page/action with id #{params[:id]}"
  end

  def member_fields
    page = movement.find_published_page(params[:id])
    member = User.find_by_email_and_movement_id(params[:email], movement.id)

    if member
      fields_to_display = member_fields_to_display(page.non_hidden_user_details, member.entered_fields)
    else
      fields_to_display = page.non_hidden_user_details
    end

    fields_to_display.delete('postcode') if should_delete_postcode params, member

    render :json => {
      :member_fields => fields_to_display,
    }, :callback => params[:callback]
  end

  def take_action
    @page = movement.find_published_page(params[:id])
    #VERSION: accepting both platform_member and member_info params keys for backwards compatibility.
    member_attributes = (params[:member_info] || params[:platform_member]).merge(:movement_id => movement.id, :language => Language.find_by_iso_code(params[:locale]))

    member_scope = User.for_movement(movement).where(:email => member_attributes[:email])
    member = member_scope.first || member_scope.build

    begin
      member.take_action_on!(@page, action_info_from(params), member_attributes)

      render :status => :created,
              :json => {
                :next_page_identifier => @page.next.try(:slug),
                :member_id => member.id
              }
    rescue DuplicateActionTakenError => duplicated_action_taken
      render :status => :bad_request,
              :json => {
                :next_page_identifier => @page.next.try(:slug),
                :error => 'Member already took this action'
              }
    rescue => error
      render :status => :internal_server_error,
              :json => {
                :next_page_identifier => @page.next.try(:slug),
                :error => error.class.name.underscore
              }
    end
  end

  def donation_payment_error
    page = movement.find_published_page(params[:id])
    donation_error = DonationError.new({ :movement => movement, :action_page => page }
                                          .merge((params[:payment_error_data] || {})
                                          .merge(params[:member_info] || {})).symbolize_keys!)
    PaymentErrorMailer.delay.report_error(donation_error)

    render :nothing => true, :status => :ok
  end

  def preview
    page = ActionPage.unscoped.find(params[:id])
    language = Language.find_by_iso_code(I18n.locale)
    render :json => merge_join_and_member_count_attrs(page.as_json(language: language), page)
  rescue ActiveRecord::RecordNotFound
    render :status => :not_found, :text => "Can't find page/action with id #{params[:id]}"
  end

  def share_counts
    page_id = params[:id]
    
    return 400 if page_id.blank?

    render :json => Share.counts(page_id)
  end

  private

  def should_delete_postcode(params, member)
    country_iso = params[:country_iso]
    country_iso = member.country_iso if country_iso.blank? and member

    return is_non_post_code_country(country_iso)
  end

  def member_fields_to_display(displayable_fields, entered_fields)
    entered_fields = map_user_attribute_keys_to_page_required_user_details_keys(entered_fields)
    displayable_fields.delete_if do |k,v|
      case v.to_sym
      when :required, :optional
        entered_fields.include?(k.to_s)
      when :refresh
        false
      end
    end

  end

  def merge_join_and_member_count_attrs(page_as_json, page)
    page_as_json.merge(is_join_page: page.is_join?, member_count: MemberCountCalculator.current_member_count(movement, I18n.locale))
  end

  def map_user_attribute_keys_to_page_required_user_details_keys(user_attributes)
    map = {'country_iso' => 'country'}

    mapped_attributes = user_attributes.collect do |attr|
      mapping = map[attr]
      mapping ? mapping : attr
    end
    mapped_attributes
  end

  def action_info_from(params)
    action_info = (params[:action_info].is_a? Hash) ? params[:action_info] : {}
    action_info.merge(:email => tracked_email)
  end

end
