module Admin
  class CampaignsController < AdminController
    layout 'movements'
    self.nav_category = :campaigns

    PAGE_SIZE = 5

    crud_actions_for Campaign, :parent => Movement, :redirects => {
      :create  => lambda { admin_movement_campaign_path(@movement, @campaign) },
      :update  => lambda { admin_movement_campaign_path(@movement, @campaign) },
      :destroy => lambda { admin_movement_campaigns_path(@movement) }
    }

    def index
      pagination_options = {:per_page => PAGE_SIZE, :page => params[:page], :order => 'updated_at DESC'}
      pagination_options.merge!(:conditions => ['lower(name) like ?', "%#{params[:query].downcase}%"]) if params[:query]
      @campaigns = @movement.campaigns.includes(:action_sequences => :action_pages).paginate(pagination_options)
    end

    def pushes_for_combo
      pushes_on_campaign = []
      @campaign.pushes.each do |push|
        pushes_on_campaign << {:label => push.name, :value => push.id}
      end
      render :json => pushes_on_campaign
    end

    def show
      pagination_options = {:per_page => PAGE_SIZE, :page => params[:page], :order => 'created_at DESC', :conditions => {:campaign_id => @campaign.id}}
      @sequences = ActionSequence.includes(:action_pages).paginate(pagination_options)
      @pushes = Push.paginate(pagination_options)
      @stats = ask_stats(@campaign, params[:page])
      @share_stats = CampaignShareStat.where(:campaign_id => @campaign.id)
    end

    def ask_stats_report
      authorize! :export, AskStatsTable
      report = AskStatsTable.new(Campaign.find_by_sql(@campaign.build_stats_query))
      send_data(report.to_csv, :type => 'text/csv', :filename => "Ask Stats for #{@campaign.name} (#{Date.today}).csv")
    end

    private

    def ask_stats(campaign, page)
      page = params[:page] || 1

      Rails.cache.fetch("campaign_#{campaign.id}_ask_stats_page_#{page}", :expires_in => 5.minutes) do
        Campaign.paginate_by_sql(campaign.build_stats_query, :per_page => PAGE_SIZE, :page => page)
      end
    end
  end
end
