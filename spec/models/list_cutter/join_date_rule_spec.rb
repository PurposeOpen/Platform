require "spec_helper"

describe ListCutter::JoinDateRule do

  before do
    @movement = create(:movement)
    @recently = "11/26/2012"
    @less_recently = "11/25/2012"
    @joined_recently = create(:user, :created_at => DateTime.parse('2012-11-26 07:07:12'), :movement => @movement)
    @joined_less_recently = create(:user, :created_at => Date.parse('2012-11-25'), :movement => @movement)
  end
  
  def str_date(date)
    date.strftime("%m/%d/%Y")
  end

  it "should check subscription date before" do
    rule = ListCutter::JoinDateRule.new(:join_date => @recently, :operator => "before", :movement => @movement)
    rule.to_relation.all.should == [ @joined_less_recently ]
  end

  it "should check subscription date on" do
    rule = ListCutter::JoinDateRule.new(:join_date => @recently, :operator => "on", :movement => @movement)
    rule.to_relation.all.should == [ @joined_recently ]
  end

  it "should check subscription date after" do
    rule = ListCutter::JoinDateRule.new(:join_date => @less_recently, :operator => "after", :movement => @movement)
    rule.to_relation.all.should == [ @joined_recently ]
  end

  it "should validate itself" do
    rule = ListCutter::JoinDateRule.new()
    rule.valid?.should be_false
    rule.errors.messages == {:operator => ["Please select a filter criteria"], :join_date => ["Please specify a join date"]}
  end

  it "should return human readable form of conditions" do
    ListCutter::JoinDateRule.new(:join_date => @recently, :operator => "before").to_human_sql.should == "Join Date is before #{@recently}"
  end
end
