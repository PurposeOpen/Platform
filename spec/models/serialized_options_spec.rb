require 'spec_helper'

module TestClass
  class ContentModule < ActiveRecord::Base
    include SerializedOptions
    option_fields :accepts_cats, :accepts_dogs, :dispenses_cats, :dispenses_dogs
  end
end

describe SerializedOptions do

  before do
    @content_module = TestClass::ContentModule.new

    @content_module.options = {
      :accepts_cats => true,
      'accepts_dogs' => true
    }
  end

  it "should allow setting the options hash directly and convert symbol keys to strings when reading" do
    @content_module.options.should == {
      'accepts_cats' => true,
      'accepts_dogs' => true 
    }
    @content_module.options_with_discerning_access.should == {:accepts_cats => true, 'accepts_dogs' => true}
  end

  it "options should be a hash with indifferent access" do
    @content_module.options.should be_an_instance_of(HashWithIndifferentAccess)
  end

  it "should build setter and getter methods for options" do
    @content_module.dispenses_cats = true
    @content_module.dispenses_cats.should be_true
    @content_module.options['dispenses_cats'].should be_true
  end

  it "should let me instantiate an object with the options" do
    module_options = {dispenses_dogs: true}
    content_module = TestClass::ContentModule.new(module_options)

    content_module.options.should == module_options.stringify_keys
    content_module.send(:read_attribute, :options).should == module_options.stringify_keys
  end

  it "should be valid if there is not a symbol and string version of the 'same' key" do
    @content_module.valid?.should be_true
  end

  it "should be invalid if there is a symbol and string version of the 'same' key" do
    @content_module.options = {
      :accepts_cats => true,
      'accepts_cats' => true
    }

    @content_module.valid?.should be_false
    @content_module.errors[:options].should include("a string key and symbol key in the options hash have the same 'name'")
  end

end