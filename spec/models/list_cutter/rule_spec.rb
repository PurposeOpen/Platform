require "spec_helper"

describe "ListCutter::Rule" do
  let(:rule) { ListCutter::Rule.new(:email => "test@test.com", :another_param => "blah") }
  it "should serialize rule options" do
    rule.to_yaml.should == "---\nrule:\n  :email: test@test.com\n  :another_param: blah\n"
  end

  it "should raise NotImplementedError for human sql" do
    rule.to_human_sql.should == "Rule (no description)"
  end
end


