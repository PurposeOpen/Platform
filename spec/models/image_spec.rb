# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  image_file_name    :string(255)
#  image_content_type :string(32)
#  image_file_size    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_height       :integer
#  image_width        :integer
#  image_description  :string(255)
#  image_resize       :boolean          default(FALSE), not null
#  created_by         :string(255)
#  updated_by         :string(255)
#  movement_id        :integer
#

require "spec_helper"

describe Image do
  before do
    @fixure_file = File.new(Rails.root + 'spec/fixtures/images/wikileaks.jpg')
  end
  it "validates presence of images" do
    img = Image.new(image: File.new(Rails.root + 'spec/fixtures/images/wikileaks.jpg'))
    img.should be_valid

    img = Image.new()
    img.should_not be_valid, img.errors
  end

  it "disallows non-image types" do
    # this reminds me of my computation theory lectures
    img = Image.new(image: File.new(__FILE__))
    img.should_not be_valid
  end

  describe "names" do
    before do
      @image = Image.create(
        id: 123,
        image: File.new('spec/fixtures/images/wikileaks.jpg'),
        movement: FactoryGirl.create(:movement)
      )
    end

    it "correctly formulates original name" do
      @image.name.should eql("#{@image.movement_slug}_image_#{@image.id}_original.jpg")
    end

    it "correctly formulates thumbnail name" do
      @image.name(:thumbnail).should eql("#{@image.movement_slug}_image_#{@image.id}_thumbnail.jpg")
    end

    after(:all) do
      Image.delete_all
    end
  end
end
