require "spec_helper"
describe ListCutter::DateRule do
  describe "Date Operator assimilation" do
    it "should set the operator value to before" do
      rule = ListCutter::DateRule.new(operator: 'before')
      rule.before?.should be_true
      rule.after?.should be_false
      rule.on?.should be_false
    end

    it "should set the operator value to after" do
      rule = ListCutter::DateRule.new(operator: 'after')
      rule.after?.should be_true
      rule.before?.should be_false
      rule.on?.should be_false
    end

    it "should set the operator value to on" do
      rule = ListCutter::DateRule.new(operator: 'on')
      rule.after?.should be_false
      rule.before?.should be_false
      rule.on?.should be_true
    end
  end

  describe "Date Operator lookup" do
    shared_examples_for "return looked up operator" do |operator_param, expected_operator|
      rule = ListCutter::DateRule.new(operator: operator_param)
      rule.query_operator.should == expected_operator
    end

    it_should_behave_like "return looked up operator", "after", ">"
    it_should_behave_like "return looked up operator", "before", "<"
    it_should_behave_like "return looked up operator", "on", "="

    it "should raise an error when operator is invalid" do
      rule = ListCutter::DateRule.new(operator: nil)
      lambda { rule.query_operator }.should raise_error

      rule = ListCutter::DateRule.new(operator: 'something')
      lambda { rule.query_operator }.should raise_error

      rule = ListCutter::DateRule.new(operator: '')
      lambda { rule.query_operator }.should raise_error
    end
  end
end