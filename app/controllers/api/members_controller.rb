class Api::MembersController < Api::BaseController
  MEMBER_FIELDS = [:id, :first_name, :last_name, :email, :country_iso, :postcode, :home_number, :mobile_number, :street_address, :suburb]
  respond_to :json

  def show
    @member = movement.members.find_by_email(params[:email]) unless params[:email].blank?

    if @member
      render :json => @member.as_json(:only => MEMBER_FIELDS), :status => :ok
    else
      status_response = params[:email].blank? ? :bad_request : :not_found
      render :nothing => true, :status => status_response
    end
  end

  def create
    (render :json => { :errors => "Language field is required"}, :status => 422 and return) if params[:member][:language].blank? 

    @member = movement.members.find_or_initialize_by_email(params[:member][:email])
    @member.language = Language.find_by_iso_code(params[:member][:language])
    if @member.valid?
      @member.join_email_sent = true
      @member.subscribe_through_homepage!(tracked_email)
      MailSender.new.send_join_email(@member, movement)

      response = @member.as_json(:only => MEMBER_FIELDS).merge({
        :next_page_identifier => join_page_slug,
        :member_id => @member.id
      })
      status_response = :created
    else
      response = {
        :errors => @member.errors.messages
      }
      status_response = 422
    end

    render :json => response, :status => status_response
  end

  private

  def join_page_slug
    movement.find_page('join').try(:slug)
  rescue
    nil
  end

  class MailSender
    def send_join_email(member, movement)
      join_email = movement.join_emails.find {|join_email| join_email.language == member.language}
      SendgridMailer.user_email(join_email, member)
    end
    handle_asynchronously(:send_join_email) unless Rails.env.test?
  end
end
