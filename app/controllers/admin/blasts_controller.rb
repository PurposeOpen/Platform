module Admin
  class BlastsController < AdminController
    layout 'movements'
    self.nav_category = :campaigns

    crud_actions_for Blast, parent: Push, redirects: {
      create:  lambda { admin_movement_push_path(@movement, @push) },
      update:  lambda { admin_movement_push_path(@movement, @push) },
      destroy: lambda { admin_movement_push_path(@movement, @push) },
    }

    def deliver
      @blast = Blast.find(params[:id])

      if(list_errors? || invalid_limit? || invalid_schedule_time_format? || past_schedule_time?)
        redirect_to admin_movement_push_path(@movement, @blast.push) and return
      end

      email_ids = [params[:email_id]] unless params[:email_id] == 'all'
      options = {limit: @limit, email_ids: email_ids}.select{|k,v| v.present? }
      @blast.send_proofed_emails!(options.merge(run_at: @run_at || Time.now.utc+AppConstants.blast_job_delay))
      Rails.logger.info @blast.push.inspect
      redirect_to admin_movement_push_path(@movement, @blast.push)
    end

    private

    def invalid_schedule_time_format?
      if(params[:run_now] != "true" && params[:run_at].present? && params[:run_at_hour].present?)
        begin
          zone = ActiveSupport::TimeZone[@blast.movement.time_zone]
          @run_at = zone.parse("#{params[:run_at]} #{params[:run_at_hour]}").utc
        rescue
          flash[:error] = 'Invalid date format'
          return true
        end
      end
      false
    end

    def past_schedule_time?
      return false unless(@run_at && @run_at < Time.now.utc+AppConstants.blast_job_delay)
      flash[:error] = "Scheduled time should be in at least #{AppConstants.blast_job_delay} minutes later than current time"
    end

    def list_errors?
      return false unless (@blast.list.nil? || @blast.list.summary.nil? ||
                           !@blast.list.summary[:number_of_selected_users].present? ||
                           @blast.list.summary[:number_of_selected_users] == 0)
      flash[:error] = 'A non-empty list of recipients must be selected.'
    end

    def invalid_limit?
      if (params[:member_count_select] == Blast::LIMIT_MEMBERS)
        @limit = params[:limit].blank? ? nil : params[:limit].to_i
        if (@limit.nil? || @limit <= 0)
          flash[:error] = 'Limit must be a number greater than 0.'
          return true
        end
      end
      false
    end
  end
end
