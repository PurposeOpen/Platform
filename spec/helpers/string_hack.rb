require "spec_helper"
require File.join(Rails.root, 'config', 'initializers', 'string_extensions.rb')

describe "string hack" do
  before do
    @original = %Q{blah blah <img src="http://lah.di.dah/path" height="123" width="34" /> blah}
  end

  it "should substitute https for http on images" do
    @original.html_linebreaks(true).should eql(%Q{blah blah <img src="https://lah.di.dah/path" height="123" width="34" /> blah})
    @original.html_linebreaks(false).should eql(%Q{blah blah <img src="http://lah.di.dah/path" height="123" width="34" /> blah})
  end
end
