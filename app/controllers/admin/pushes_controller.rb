module Admin
  class PushesController < AdminController
    layout 'movements'
    self.nav_category = :campaigns

    crud_actions_for Push, :parent => Campaign, :redirects => {
      :create  => lambda { admin_movement_push_path(@movement, @push) },
      :update  => lambda { admin_movement_campaign_path(@movement, @campaign) },
      :destroy => lambda { admin_movement_campaign_path(@movement, @campaign) },
    }

    def index
    end

    def emails_for_combo
      emails_to_return = []
      Email.where(:blast_id => Blast.select(:id).where(:push_id => @push.id)).each do |email|
        emails_to_return << {:label => email.name, :value => email.id}
      end
      render :json => emails_to_return
    end

    # overridden from Admin::CrudActions to improve page load
    def find_model
      self.model = model_class.includes(:blasts => :emails).where(:id => params[:id]).first
    end

    def email_stats_report
      authorize! :export, EmailStatsTable
      report = EmailStatsTable.new(@push.blasts.map(&:emails).flatten)
      send_data(report.to_csv, :type => 'text/csv', :filename => "Email Stats for #{@push.name} (#{Date.today}).csv")
    end

    def show
      @stats_table = EmailStatsTable.new(@push.blasts.map(&:emails).flatten)
      @campaigns = @movement.campaigns.reverse
    end
  end
end
