require 'spec_helper'

describe "admin/reportings/index" do
  before(:each) do
    assign(:admin_reporting_deliverabilities, [
      stub_model(Admin::Reporting::Deliverability,
        :report => "MyText"
      ),
      stub_model(Admin::Reporting::Deliverability,
        :report => "MyText"
      )
    ])
  end

  it "renders a list of admin/reportings" do
    pending("changing the URL structure for this")
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
