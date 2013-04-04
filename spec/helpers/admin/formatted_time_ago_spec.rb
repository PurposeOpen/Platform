require "spec_helper"

describe Admin::FormattedTimeAgoHelper do
  before do
    I18n.locale = :en
  end

  it "should return 'no action sent' when no occurrence" do
    since = helper.time_since_sent("trout fishing", false)
    since.should == "not trout fishing"
  end

  it "should return formatted time since when occurrence" do
    since = helper.time_since_sent("elephant hunting", 3.days.ago)
    since.should == "elephant hunting 3 days ago"
  end

end
