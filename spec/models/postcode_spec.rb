require 'spec_helper'

describe Postcode do
  it { should validate_presence_of :lat }
  it { should validate_presence_of :lng }
  it { should validate_presence_of :zip }
  context "when lat and lng are set" do
    subject { Postcode.create lat: "12", lng: "42", zip: "22280-020" }
    it { should validate_uniqueness_of :zip }
  end
end
