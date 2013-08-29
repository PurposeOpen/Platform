require 'spec_helper'

describe "admin/reportings/edit" do
  before(:each) do
    @admin_reporting = assign(:admin_reporting, stub_model(Admin::Reporting::Deliverability,
      :report => "MyText"
    ))
  end

  it "renders the edit admin_reporting form" do
    pending("changing the URL structure for this")
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_reporting_path(@admin_reporting), "post" do
      assert_select "textarea#admin_reporting_report[name=?]", "admin_reporting[report]"
    end
  end
end
