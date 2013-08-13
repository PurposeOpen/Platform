require "spec_helper"

describe ListCutter::DistanceFromPostcodeRule do
  before do
    @movement = create(:movement)
    @params = {postcode: 10036, country_iso: 'us', distance: 500, distance_unit: 'miles', movement: @movement}
  end

  it { should validate_presence_of(:postcode) }
  it { should validate_presence_of(:country_iso).with_message("Please specify the country iso") }
  it { should validate_presence_of(:distance) }
  it { should ensure_inclusion_of(:distance_unit).in_array(ListCutter::DistanceFromPostcodeRule::DISTANCE_UNITS) }

  it 'should return users within a radius of a postcode' do
    bob = create(:user, lat: '38', lng: '-80', movement: @movement, first_name: 'bob')
    sally = create(:user, lat: '40', lng: '-74', movement: @movement, first_name: 'sally')
    jenny = create(:user, lat: '38', lng: '-89', movement: @movement, first_name: 'jenny')

    mock_geo_datum = mock(GeoData, lat: '40.75794', lng: '-73.9904')
    GeoData.should_receive(:find_by_country_iso_and_postcode).with(@params[:country_iso], @params[:postcode].to_s).and_return(mock_geo_datum)
    rule = ListCutter::DistanceFromPostcodeRule.new(@params)

    rule.to_relation.all.should =~ [bob, sally]
  end

  context 'postcode does not exist in geo_data table' do
    it 'should raise an error' do
      rule = ListCutter::DistanceFromPostcodeRule.new(@params)

      lambda { rule.to_relation }.should raise_error(GeoDataNotFoundError,
               "could not find postcode #{@params[:postcode]} for country #{@params[:country_iso]}")
    end
  end

  it 'should ensure postcodes are strings' do
      rule = ListCutter::DistanceFromPostcodeRule.new(@params)

      rule.postcode.should == @params[:postcode].to_s
  end

  describe "#to_human_sql" do

    it "should return rule conditions in human readable form" do
      rule = ListCutter::DistanceFromPostcodeRule.new(@params).to_human_sql.should ==
          "Members are within #{@params[:distance]} #{@params[:distance_unit]} of #{@params[:postcode]}, #{@params[:country_iso].upcase}"
    end

  end

end