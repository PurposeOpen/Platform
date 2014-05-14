require 'spec_helper'

shared_examples_for "content module with disabled content" do |module_type|
  it "should include disabled content fields" do
    content_module = FactoryGirl.create(module_type, active: false,
        disabled_title: 'Disabled Title', disabled_content: 'Disabled Content')

    json = JSON.parse(content_module.to_json)
    json['options']['active'].should == false
    json['options']['disabled_title'].should == 'Disabled Title'
    json['options']['disabled_content'].should == 'Disabled Content'
  end
end
