require 'spec_helper'

describe ListCutter::MemberSourceRule do
  describe "to_human_sql" do
    it "should return human readable form of conditions" do
      ListCutter::MemberSourceRule.new(sources: ['Movement','Change.org'], not: false).to_human_sql.should == "Member source is any of these: Movement, Change.org"
      ListCutter::MemberSourceRule.new(sources: ['Movement','Change.org'], not: true).to_human_sql.should == "Member source is not any of these: Movement, Change.org"
    end
  end
end