require "spec_helper"

describe CopyAttributeWithNextVersion do
  before(:each) do
    @model = :action_sequence
    @attribute = :name
  end

  it "should return the copy of attribute" do
    create(@model, @attribute =>  "Name")
    create(@model, @attribute => "Name(1)")
    action_sequence = build(@model, @attribute => "Name")
    action_sequence.copy_attribute_with_next_version(@attribute).should == "Name(2)"
  end

  it "should return the copy of attribute even if it has a version number" do
    create(@model, @attribute =>  "Name")
    create(@model, @attribute => "Name(1)")
    action_sequence = build(@model, @attribute => "Name(1)")
    action_sequence.copy_attribute_with_next_version(@attribute).should == "Name(2)"
  end

  it "should return the copy of attribute even if it has a version number more than 1 digit" do
    create(@model, @attribute =>  "Name")
    create(@model, @attribute => "Name(100)")
    action_sequence = build(@model, @attribute => "Name(50)")
    action_sequence.copy_attribute_with_next_version(@attribute).should == "Name(101)"
  end

end