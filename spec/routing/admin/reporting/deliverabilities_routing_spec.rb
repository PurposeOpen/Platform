require "spec_helper"

describe Admin::Reporting::DeliverabilitiesController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/reportings").should route_to("admin/reportings#index")
    end

    it "routes to #new" do
      get("/admin/reportings/new").should route_to("admin/reportings#new")
    end

    it "routes to #show" do
      get("/admin/reportings/1").should route_to("admin/reportings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/reportings/1/edit").should route_to("admin/reportings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/reportings").should route_to("admin/reportings#create")
    end

    it "routes to #update" do
      put("/admin/reportings/1").should route_to("admin/reportings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/reportings/1").should route_to("admin/reportings#destroy", :id => "1")
    end

  end
end
