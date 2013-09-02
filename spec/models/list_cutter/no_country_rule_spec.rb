require "spec_helper"

describe ListCutter::NoCountryRule do
  describe "to_human_sql" do
    it "should return human readable form of no conuntry" do
      ListCutter::NoCountryRule.new.to_human_sql.should == "User has No Country (country_iso is null)"
      ListCutter::NoCountry.new.to_human_sql.should == "User has No Country (country_iso is null)"
    end
  end
end
