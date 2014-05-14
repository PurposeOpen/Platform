module Admin
  class UserActivityEventsController < AdminController
    def index
      action_sequence = ActionSequence.find(params[:action_sequence_id])
      activities = UserActivityEvent.actions_taken_for_sequence(action_sequence)
      report = ActivitiesReport.new(activities)
      send_data(report.to_csv, type: 'text/csv', filename: csv_filename(@movement, action_sequence))
    end

    private

    def csv_filename(movement, action_sequence)
      "#{movement.name.parameterize}-#{action_sequence.name.parameterize}-activities-#{Time.now.to_s(:report)}.csv"
    end
  end
end