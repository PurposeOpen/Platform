module Admin
class Reporting::ProviderDomainsController < AdminController
      layout 'movements'
  # GET /admin/reporting/provider_domains
  # GET /admin/reporting/provider_domains.json
  def index
    @admin_reporting_provider_domains = Admin::Reporting::ProviderDomain.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_reporting_provider_domains }
    end
  end

  # GET /admin/reporting/provider_domains/1
  # GET /admin/reporting/provider_domains/1.json
  def show
    @admin_reporting_provider_domain = Admin::Reporting::ProviderDomain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_reporting_provider_domain }
    end
  end

  # GET /admin/reporting/provider_domains/new
  # GET /admin/reporting/provider_domains/new.json
  def new
    @admin_reporting_provider_domain = Admin::Reporting::ProviderDomain.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_reporting_provider_domain }
    end
  end

  # GET /admin/reporting/provider_domains/1/edit
  def edit
    @admin_reporting_provider_domain = Admin::Reporting::ProviderDomain.find(params[:id])
  end

  # POST /admin/reporting/provider_domains
  # POST /admin/reporting/provider_domains.json
  def create
    @admin_reporting_provider_domain = Admin::Reporting::ProviderDomain.new(params[:admin_reporting_provider_domain])

    respond_to do |format|
      if @admin_reporting_provider_domain.save
        format.html { redirect_to @admin_reporting_provider_domain, notice: 'Provider domain was successfully created.' }
        format.json { render json: @admin_reporting_provider_domain, status: :created, location: @admin_reporting_provider_domain }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_reporting_provider_domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/reporting/provider_domains/1
  # PUT /admin/reporting/provider_domains/1.json
  def update
    @admin_reporting_provider_domain = Admin::Reporting::ProviderDomain.find(params[:id])

    respond_to do |format|
      if @admin_reporting_provider_domain.update_attributes(params[:admin_reporting_provider_domain])
        format.html { redirect_to @admin_reporting_provider_domain, notice: 'Provider domain was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_reporting_provider_domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/reporting/provider_domains/1
  # DELETE /admin/reporting/provider_domains/1.json
  def destroy
    @admin_reporting_provider_domain = Admin::Reporting::ProviderDomain.find(params[:id])
    @admin_reporting_provider_domain.destroy

    respond_to do |format|
      format.html { redirect_to admin_reporting_provider_domains_url }
      format.json { head :no_content }
    end
  end
end
end
