require 'spec_helper'

describe "admin/reportings/edit" do
  before(:each) do
    @admin_reporting = assign(:admin_reporting, stub_model(Admin::Reporting::ProviderDomain,
      :domain => "MyString",
      :provider => "MyString"
    ))
  end

  it "renders the edit admin_reporting form" do
    pending("changing the URL structure for this")
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_reporting_path(@admin_reporting), "post" do
      assert_select "input#admin_reporting_domain[name=?]", "admin_reporting[domain]"
      assert_select "input#admin_reporting_provider[name=?]", "admin_reporting[provider]"
    end
  end
end
