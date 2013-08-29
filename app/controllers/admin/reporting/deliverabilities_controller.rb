module Admin
class Reporting::DeliverabilitiesController < AdminController
      layout 'movements'
  # GET /admin/reporting/deliverabilities
  # GET /admin/reporting/deliverabilities.json
  def index
    @admin_reporting_deliverabilities = Admin::Reporting::Deliverability.order('target_date desc').all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_reporting_deliverabilities }
    end
  end

  # GET /admin/reporting/deliverabilities/1
  # GET /admin/reporting/deliverabilities/1.json
  def show
    @admin_reporting_deliverability = Admin::Reporting::Deliverability.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_reporting_deliverability }
    end
  end

  # GET /admin/reporting/deliverabilities/new
  # GET /admin/reporting/deliverabilities/new.json
  def new
    @admin_reporting_deliverability = Admin::Reporting::Deliverability.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_reporting_deliverability }
    end
  end

  # GET /admin/reporting/deliverabilities/1/edit
  def edit
    @admin_reporting_deliverability = Admin::Reporting::Deliverability.find(params[:id])
  end

  # POST /admin/reporting/deliverabilities
  # POST /admin/reporting/deliverabilities.json
  def create
    @admin_reporting_deliverability = Admin::Reporting::Deliverability.new(params[:admin_reporting_deliverability])

    respond_to do |format|
      if @admin_reporting_deliverability.save
        format.html { redirect_to admin_movement_reporting_deliverabilities_path(@movement), notice: 'Deliverability was successfully created.' }
        format.json { render json: @admin_reporting_deliverability, status: :created, location: admin_movement_reporting_deliverability_path(@movement,@admin_reporting_deliverability) }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_reporting_deliverability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/reporting/deliverabilities/1
  # PUT /admin/reporting/deliverabilities/1.json
  def update
    @admin_reporting_deliverability = Admin::Reporting::Deliverability.find(params[:id])

    respond_to do |format|
      if @admin_reporting_deliverability.update_attributes(params[:admin_reporting_deliverability])
        format.html { redirect_to admin_movement_reporting_deliverabilities_path(@movement), notice: 'Deliverability was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_reporting_deliverability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/reporting/deliverabilities/1
  # DELETE /admin/reporting/deliverabilities/1.json
  def destroy
    @admin_reporting_deliverability = Admin::Reporting::Deliverability.find(params[:id])
    @admin_reporting_deliverability.destroy

    respond_to do |format|
      format.html { redirect_to admin_movement_reporting_deliverabilities_url(@movement) }
      format.json { head :no_content }
    end
  end
end
end
