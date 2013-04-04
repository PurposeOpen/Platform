require "spec_helper"

describe Admin::MovementHelper do
  it "should return a comma separated list of languages sorted by name" do
    movement = FactoryGirl.create(:movement, :languages => [FactoryGirl.create(:portuguese), FactoryGirl.create(:english)])

    helper.movement_languages(movement).should eql "Portuguese (default) and English"
  end

  it "should highlight the default language if the movement has one" do
    english = FactoryGirl.create(:english)
    movement = FactoryGirl.create(:movement, :languages => [FactoryGirl.create(:portuguese), english, FactoryGirl.create(:french)])
    movement.default_language = english

    helper.movement_languages(movement).should eql "English (default), French, and Portuguese"
  end

  it "should default to the only selected language" do
    english = FactoryGirl.create(:english)
    movement = FactoryGirl.create(:movement, :languages => [english])
    movement.default_language = english

    helper.movement_languages(movement).should eql "English (default)"
  end
end
