require 'spec_helper'

describe "admin/reportings/show" do
  before(:each) do
    @admin_reporting = assign(:admin_reporting, stub_model(Admin::Reporting::Deliverability,
      :report => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    pending("changing the URL structure for this")
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
