require 'spec_helper'

describe ExternalTag do

  it { should validate_presence_of(:movement_id) }
  it { should validate_presence_of(:name) }

  it 'should validate uniqueness of name within scope movement_id' do
    tag_attributes = {movement_id: 1, name: 'tag'}
    ExternalTag.create!(tag_attributes)

    duplicate_tag = ExternalTag.new(tag_attributes)
    duplicate_tag.valid?.should be_false
    duplicate_tag.errors.messages.should == {name: ["has already been taken"]}
  end

end
