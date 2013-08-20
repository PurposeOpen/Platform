require "spec_helper"

describe ListCutter::DistanceFromPointRule do
  before do
    @movement = create(:movement)
    @params = {lat: '40.76494141246851', lng: '-73.97609710693365', distance: 500, distance_unit: 'miles', movement: @movement}
  end

  it { should validate_presence_of(:lat) }
  it { should validate_presence_of(:lng) }
  it { should validate_presence_of(:distance) }
  it { should ensure_inclusion_of(:distance_unit).in_array(ListCutter::DistanceFromPostcodeRule::DISTANCE_UNITS) }

  it 'should return users within a distance from a point' do
    bob = create(:user, lat: '38', lng: '-80', movement: @movement, first_name: 'bob')
    sally = create(:user, lat: '40', lng: '-74', movement: @movement, first_name: 'sally')
    jenny = create(:user, lat: '38', lng: '-89', movement: @movement, first_name: 'jenny')

    rule = ListCutter::DistanceFromPointRule.new(@params)

    rule.to_relation.all.should =~ [bob, sally]
  end

  describe "#to_human_sql" do

    it "should return rule conditions in human readable form" do
      rule = ListCutter::DistanceFromPointRule.new(@params).to_human_sql.should ==
          "Members are within #{@params[:distance]} #{@params[:distance_unit]} of [lat: #{@params[:lat]}, lng: #{@params[:lng]}]"
    end

  end

end