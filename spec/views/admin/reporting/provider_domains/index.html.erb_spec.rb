require 'spec_helper'

describe "admin/movements/reporting/index" do

  before(:each) do
    assign(:admin_reporting_provider_domains, [
      stub_model(Admin::Reporting::ProviderDomain,
        :domain => "Domain",
        :provider => "Provider"
      ),
      stub_model(Admin::Reporting::ProviderDomain,
        :domain => "Domain",
        :provider => "Provider"
      )
    ])
  end

  it "renders a list of admin/reportings" do
    pending("changing the URL structure for this")
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Domain".to_s, :count => 2
    assert_select "tr>td", :text => "Provider".to_s, :count => 2
  end
end
