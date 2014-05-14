module Admin
  class EmailsController < AdminController
    layout 'movements'
    self.nav_category = :campaigns

    crud_actions_for Email, parent: Blast, redirects: {
      create:  lambda { redirect_to_after_save },
      update:  lambda { redirect_to_after_save },
      destroy: lambda { admin_movement_push_path(@movement, @blast.push) }
    }
    after_filter :send_test_email, only: [:create, :update]

    def index
      emails_to_return = Email.all
      returnArray = []
      emails_to_return.each do |email|
          returnArray << {label: email.name, value:email.id}
      end
      render json: returnArray
    end

    def clone
      @email = Email.find(params[:email_id])
      attributes_to_ignore = @email.attributes.keys - ['subject', 'from', 'reply_to', 'body', 'language_id', 'blast_id']
      @email = @email.dup({except: attributes_to_ignore})
      render :new
    end

    def cancel_schedule
      email = Email.find(params[:email_id])
      notice = email.cancel_schedule ? 'Delivery canceled' : 'No deliveries in progress to be canceled'
      redirect_to admin_movement_push_path(email.blast.movement, email.blast.push), notice: notice
    end

    private

    def should_proof_email?
      !params[:save_send].nil?
    end

    def redirect_to_after_save
      if should_proof_email?
        admin_movement_push_path(@movement, @blast.push)
      else
        edit_admin_movement_email_path(@movement, @email)
      end
    end

    def send_test_email
      return if @email.new_record? || !@email.valid?

      if should_proof_email?
        emails = params[:test_recipients].gsub(/\s*/, '').split(',')
        @email.send_test!(emails)
        flash[:proofed] = {email: @email.id, status: 'proof queued for sending'}
        flash[:notice] << ' Test blast sent.'
      else
        @email.clear_test_timestamp!
      end
    end
  end
end
