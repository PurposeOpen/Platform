require 'spec_helper'

describe "admin/reportings/new" do
  before(:each) do
    assign(:admin_reporting, stub_model(Admin::Reporting::ProviderDomain,
      :domain => "MyString",
      :provider => "MyString"
    ).as_new_record)
  end

  it "renders new admin_reporting form" do
    pending("changing the URL structure for this")
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admin_reporting_provider_domains_path, "post" do
      assert_select "input#admin_reporting_domain[name=?]", "admin_reporting[domain]"
      assert_select "input#admin_reporting_provider[name=?]", "admin_reporting[provider]"
    end
  end
end
