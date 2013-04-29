require "spec_helper"

describe Admin::ImagesHelper do
  before do
    @image = Image.create(
      :id => 123, 
      :image => File.new(Rails.root + 'spec/fixtures/images/wikileaks.jpg'),
      :movement => FactoryGirl.create(:movement)
    )
  end

  it "translates local paths to URLs" do
    S3[:enabled] = false
    helper.image_url(@image, :thumbnail).should eql("https://#{@request.host_with_port}/system/#{@image.movement_slug}_image_#{@image.id}_thumbnail.jpg")
    helper.image_url(@image, :original).should eql("https://#{@request.host_with_port}/system/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
    helper.image_url(@image).should eql("https://#{@request.host_with_port}/system/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
  end

  it "translates CDN paths to correct URLs" do
    Rails.application.config.action_controller.asset_host = "http://xyz.s3.amazonaws.com"
    S3[:enabled] = true
    S3[:bucket] = "xyz"
    helper.image_url(@image, :thumbnail).should eql("https://xyz.s3.amazonaws.com/#{@image.movement_slug}_image_#{@image.id}_thumbnail.jpg")
    helper.image_url(@image).should eql("https://xyz.s3.amazonaws.com/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
  end
end
