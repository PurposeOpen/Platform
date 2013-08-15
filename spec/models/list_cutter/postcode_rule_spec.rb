require "spec_helper"

describe ListCutter::PostcodeRule do
  let(:movement)  { FactoryGirl.create(:movement) }
  let(:geo_data)  { FactoryGirl.create :geo_data, postcode: "123456", country_iso: "us" }
  subject         { ListCutter::PostcodeRule.new postcodes: geo_data.postcode, country_iso: geo_data.country_iso, movement: movement }
  
  context "when nobody lives in this postcode" do
    its(:to_relation) { should be_empty }
  end

  context "when somebody lives in this postcode" do
    before            { FactoryGirl.create :user, postcode: geo_data.postcode, country_iso: geo_data.country_iso, movement_id: movement.id }
    its(:to_relation) { should_not be_empty }
  end
end
