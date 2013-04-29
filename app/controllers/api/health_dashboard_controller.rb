class Api::HealthDashboardController < ApplicationController
  layout 'health_dashboard'

  def index
    @service_statuses = {
        services: {}
    }

    @service_statuses[:services] = @service_statuses[:services].merge(db_status)
    @service_statuses[:services] = @service_statuses[:services].merge(mail_status)
    @service_statuses[:services] = @service_statuses[:services].merge(platform_status)
    @service_statuses[:services] = @service_statuses[:services].merge(delayed_jobs_status)


    respond_to do |format|
      format.html
      format.json { render json: @service_statuses }
    end
  end

  def delayed_jobs_status
    dj_count = Delayed::Job.where("attempts >= #{Delayed::Worker.max_attempts}").count
    if dj_count == 0
      {delayedJobs: 'OK'}
    else
      {delayedJobs: "CRITICAL - Dead jobs: #{dj_count}"}
    end
  end

  def db_status
    ActiveRecord::Base.connection.execute('show global status;')
    {database: 'OK'}
  rescue ActiveRecord::StatementInvalid => e
    {database: "CRITICAL - Error: #{e.message}"}
  end
  private :db_status

  def mail_status
    response = Net::HTTP.get_response(URI(AppConstants.send_grid_health_check_uri))
    if response.code.to_s == '200'
      {mail: 'OK'}
    else
      {mail: "CRITICAL - response code: #{response.code}"}
    end
  rescue Exception => e
    {mail: "CRITICAL - Error: #{e.message}"}
  end
  private :mail_status

  def platform_status
    case
      when @service_statuses[:services][:database].include?('CRITICAL')
        {platform: 'CRITICAL - database is down'}
      when @service_statuses[:services][:mail].include?('CRITICAL')
        {platform: 'WARNING - mail is down'}
      else
        {platform: 'OK'}
    end
  end
  private :platform_status
end
