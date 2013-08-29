require 'spec_helper'

describe "admin/reportings/show" do
  before(:each) do
    @admin_reporting = assign(:admin_reporting, stub_model(Admin::Reporting::ProviderDomain,
      :domain => "Domain",
      :provider => "Provider"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Domain/)
    rendered.should match(/Provider/)
  end
end
