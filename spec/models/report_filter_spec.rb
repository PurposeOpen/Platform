require "spec_helper"

describe ReportFilter do
  it "should create an order clause" do
    @rf = ReportFilter.new :order_by => 'widget', :order_direction => 'DESC'
    @rf.order_clause.should eql({ :order => 'widget DESC' })
  end
  it "should give blank order clause" do
    @rf = ReportFilter.new
    @rf.order_clause.should be_blank
  end
  it "should create integer clauses" do
    @rf = ReportFilter.new :page => 4
    @rf.integer_clauses.should eql({ :page => 4 })
  end
end
