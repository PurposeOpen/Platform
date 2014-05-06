require "spec_helper"

describe ListCutter::EmailDomainRule do
  it "should filter by email" do
    movement = create(:movement)
    user_basic = create(:user, :email => "test@example.com", :movement => movement)
    user_same_domain = create(:user, :email => "best@example.com", :movement => movement)
    user_diff_domain = create(:user, :email => "rest@gmail.com", :movement => movement)
    rule = ListCutter::EmailDomainRule.new(:domain => "test@example.com", :movement => movement)
    rule.to_relation.all.should match_array([ user_basic, user_same_domain ])
  end

  it "should validate itself" do
    rule = ListCutter::EmailDomainRule.new

    rule.valid?.should be_false
    rule.errors.messages == {:domain=>["Please specify the email server"]}
  end

  it "should return human readable form of conditions" do
    ListCutter::EmailDomainRule.new(domain: "test@test.com", not: false).to_human_sql.should == "Domain is test.com"
    ListCutter::EmailDomainRule.new(domain: "test@test.com", not: true).to_human_sql.should == "Domain is not test.com"
  end

end


