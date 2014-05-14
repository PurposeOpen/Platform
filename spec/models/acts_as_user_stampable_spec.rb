require "spec_helper"

describe ActsAsUserStampable do
  describe ActionPage do
    before do
      PlatformUser.current_user = PlatformUser.new(
        first_name: 'Fred',
        last_name: 'Smith',
        email: 'fred@example.com'
      )
    end

    it "should populate created_by on create" do
      p = FactoryGirl.create(:action_page)
      p.created_by.should eql('Fred Smith')
    end

    it "should update updated_by and leave created_by unchanged" do
      p = FactoryGirl.create(:action_page)

      PlatformUser.current_user = PlatformUser.new(
        first_name: 'John',
        last_name: 'Howard',
        email: 'johhnie@example.com'
      )

      p.name = "Blah blah blah"
      p.save
      p.created_by.should eql('Fred Smith')
      p.updated_by.should eql('John Howard')
    end
  end
end