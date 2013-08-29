require 'spec_helper'

describe "Admin::Reporting::Deliverabilities" do
  describe "GET /admin_reporting_deliverabilities" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get admin_reporting_deliverabilities_path
      response.status.should be(200)
    end
  end
end
