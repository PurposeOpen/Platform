require 'spec_helper'

describe "Admin::Reporting::ProviderDomains" do
  describe "GET /admin_reporting_provider_domains" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get admin_reporting_provider_domains_path
      response.status.should be(200)
    end
  end
end
