class DonationError
	attr_accessor :movement, :action_page,
								:error_code, :message, :reference,
								:member_first_name, :member_last_name, :member_email, :member_country_iso, :member_language_iso,
  :donation_payment_method, :donation_amount_in_cents, :donation_currency

	def initialize(attributes)
		if attributes.nil? || attributes.empty?
			return
 		end

		@movement = attributes[:movement]
		@action_page = attributes[:action_page]
		@error_code = attributes[:error_code] || ''
		@message = attributes[:message]
		@member_first_name = attributes[:first_name] || ''
		@member_last_name = attributes[:last_name] || ''
		@member_email = attributes[:email] || ''
		@member_country_iso = attributes[:country_iso] || ''
		@member_language_iso = attributes[:language_iso] || 'en'
    @donation_payment_method = attributes[:donation_payment_method]
		@donation_amount_in_cents = attributes[:donation_amount_in_cents]
		@donation_currency = attributes[:donation_currency]
    @reference = attributes[:reference]

	end
end