require "spec_helper"

describe Country do
  it "should produce a list for a Rails select helper" do
    options = Country.select_options
    options.first.should == ["AFGHANISTAN", "AFGHANISTAN"]
    options.last.should ==  ["ZIMBABWE", "ZIMBABWE"]
  end

  it "should produce a list with the country zone codes for a Rails select helper" do
    options = Country.zone_select_options
    options.first.should == ["1", 1]
    options.last.should == ["4", 4]
    options.size.should == 4
  end

  it "should produce a list of countries by zone code" do
    Country.countries_in_zone(1).should include "BR"
    Country.countries_in_zone(1).should include "US"
    Country.countries_in_zone("1").should include "NI"
    Country.countries_in_zone(1).should_not include "EE"
    Country.countries_in_zone(1).should_not include "GR"
    Country.countries_in_zone(1).should_not include "DK"

    Country.countries_in_zone(2).should include "EE"
    Country.countries_in_zone("2").should include "GR"
    Country.countries_in_zone(2).should include "DK"
    Country.countries_in_zone(2).should_not include "BR"
    Country.countries_in_zone(2).should_not include "US"
    Country.countries_in_zone(2).should_not include "NI"
  end

  describe 'searchable' do
    it 'should be searchable by name' do
      Country.iso_codes_with(:name, ['YEMEN', 'BRAZIL']).should be_same_array_regardless_of_order(['YE', 'BR'])
      Country.iso_codes_with('name', ['YEMEN', 'BRAZIL']).should be_same_array_regardless_of_order(['YE', 'BR'])
    end

    it 'should be searchable by region_id' do
      matching_isos = ["AI", "AG", "AW", "BS", "BB", "BW", "KY", "CU", "DM", "DO", "GD", "GP", "HT", "JM",
        "LS", "MQ", "MS", "NA", "PR", "KN", "LC", "VC", "ZA", "SZ", "TT", "TC", "UM", "VG", "VI"]
      Country.iso_codes_with(:region_id, ['4', '6']).should be_same_array_regardless_of_order(matching_isos)
      Country.iso_codes_with('region_id', ['4', '6']).should be_same_array_regardless_of_order(matching_isos)
    end

    it 'should be searchable by commonwealth status' do
      matching_isos = ["AG", "AU", "BS", "BD", "BB", "BZ", "BW", "BN", "CM", "CA", "CK", "CY", "DM", "GM", "GH", "GD", "GY", "IN",
        "JM", "KE", "KI", "LS", "MW", "MY", "MV", "MT", "MU", "MS", "MZ", "NA", "NR", "NZ", "NG", "NF", "PK", "PG", "RW", "KN", "LC",
        "VC", "WS", "SC", "SL", "SG", "SB", "ZA", "LK", "SZ", "TZ", "TK", "TO", "TT", "TV", "UG", "GB", "VU", "ZM"]
      Country.iso_codes_with(:commonwealth, ['true']).should be_same_array_regardless_of_order(matching_isos)
      Country.iso_codes_with('commonwealth', ['true']).should be_same_array_regardless_of_order(matching_isos)
    end
  end

  describe "region_names_for_ids" do
    it "should return region names given ids" do
      Country.region_names_for_ids(['1', '2']).should == ["Africa - Eastern Africa", "Africa - Middle Africa"]
      Country.region_names_for_ids(['1', '2', nil]).should == ["Africa - Eastern Africa", "Africa - Middle Africa"]
    end
  end

end
