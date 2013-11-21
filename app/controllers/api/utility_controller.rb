class Api::UtilityController < ApplicationController
	def unsubscribe_permanently
		user = User.where(:email => sanitize_email(params[:email])).first
		if user
			user.permanently_unsubscribe!(nil,"unsubscribed_by_bulk")
			render status: 201, nothing: true
		else
			render status: 200, nothing: true
		end
	end

	private

	def sanitize_email(email)
		unless email.blank?
		  return email.downcase.strip
		else
			return nil
		end
	end
end