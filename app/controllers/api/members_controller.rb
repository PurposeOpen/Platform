class Api::MembersController < Api::BaseController

  respond_to :json

  def member_info
    @member = movement.members.find_by_email(params[:email])
    response = @member.as_json.merge({
      :success => true,
    })  
    render :json => response, :status => response_status_for(response)
  end

  def create
    @member = movement.members.find_or_initialize_by_email(params[:member][:email])
    @member.language = Language.find_by_iso_code(I18n.locale)
    if @member.valid?
      @member.join_email_sent = true
      @member.subscribe_through_homepage!(identify_email)
      MailSender.new.send_join_email(@member, movement)

      response = @member.as_json.merge({
        :success => true,
        :next_page_identifier => join_page_slug,
        :member_id => @member.id
      })
    else
      response = {
        :success => false,
        :errors => @member.errors.messages
      }
    end

    render :json => response, :status => response_status_for(response)
  end

  private

  def response_status_for(response)
    response[:success] ? 201 : 422
  end

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
