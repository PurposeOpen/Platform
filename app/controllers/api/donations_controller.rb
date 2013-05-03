class Api::DonationsController < Api::BaseController
    def show
        donation = Donation.find_by_subscription_id(params[:subscription_id])

        if !donation
            render :status => 404, :text => "Can't find donation with subscription id #{params[:subscription_id]}"
        else
            render :json => donation.to_json(:include => [:user, :action_page])
        end
    end

	def confirm_payment
    Rails.logger.info('Payment confirmation received')

		donation = Donation.find_by_transaction_id(params[:transaction_id])
		render :status => :not_found, :text => "Can't find donation with transaction id #{params[:transaction_id]}" and return if donation.nil?

		donation.confirm

		render :nothing => true, :status => :ok
	end

	def add_payment
    Rails.logger.info('Payment added')
		donation = Donation.find_by_subscription_id(params[:subscription_id])
		render :status => :not_found, :text => "Can't find donation with subscription id #{params[:subscription_id]}" and return if donation.nil?

		donation.add_payment(params[:amount_in_cents].to_i, params[:transaction_id], params[:order_number])

		render :nothing => true, :status => :ok
	end

  def handle_failed_payment
    Rails.logger.info('Failed Payment notification received')

    page = movement.find_published_page("#{params['action_page']}")
    donation_error = DonationError.new({ :movement => movement, :action_page => page })
    donation_error.error_code = params['error_code']
    donation_error.message = params['message']
    donation_error.member_email = params['member_email']
    donation_error.reference = params['reference']

    member = movement.members.find_by_email(params['member_email'])
    donation_error.member_first_name = member.first_name
    donation_error.member_last_name = member.last_name
    donation_error.member_language_iso = member.language.iso_code
    donation_error.member_country_iso = member.country_iso

    donation = Donation.find_by_subscription_id(params['subscription_id'])
    donation_error.donation_payment_method = donation.payment_method
    donation_error.donation_amount_in_cents = params['donation_amount_in_cents']
    donation_error.donation_currency = donation.currency

    PaymentErrorMailer.delay.report_error(donation_error)

    render :nothing => true, :status => :ok
  end

end
