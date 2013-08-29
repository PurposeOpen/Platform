require 'spec_helper'

describe "admin/reportings/new" do
  before(:each) do
    assign(:admin_reporting, stub_model(Admin::Reporting::Deliverability,
      :report => "MyText"
    ).as_new_record)
  end

  it "renders new admin_reporting form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_reporting_deliverabilities_path, "post" do
      assert_select "textarea#admin_reporting_report[name=?]", "admin_reporting[report]"
    end
  end
end
