module Admin
  module HealthDashboardHelper
  
    def class_for_status(status)
      case
        when status.include?("OK")
          "green"
        when status.include?("CRITICAL")
          "red"
        else
          "yellow"
      end
    end
  end
end
