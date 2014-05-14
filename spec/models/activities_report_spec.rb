require "spec_helper"

describe ActivitiesReport do
  it "should generate csv rows" do
    row1 = ['user1', 'action_taken', 10]
    row2 = ['user2', 'action_taken', 20]
    activity1 = mock('activity', to_row: row1)
    activity2 = mock('activity', to_row: row2)
    report = ActivitiesReport.new([activity1, activity2])

    report.rows.should == [row1, row2]
  end
end