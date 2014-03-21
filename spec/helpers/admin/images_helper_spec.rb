require "spec_helper"

describe Admin::ImagesHelper do

  before do
    @image = Image.create(
      :id => 123, 
      :image => File.new(Rails.root + 'spec/fixtures/images/wikileaks.jpg'),
      :movement => FactoryGirl.create(:movement)
    )
  end

  context 'S3 disabled' do

    it "should create links to images stored on the app host" do
      S3[:enabled] = false

      helper.image_url(@image, :thumbnail).should eql("https://#{@request.host_with_port}/system/#{@image.movement_slug}_image_#{@image.id}_thumbnail.jpg")
      helper.image_url(@image, :original).should eql("https://#{@request.host_with_port}/system/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
      helper.image_url(@image).should eql("https://#{@request.host_with_port}/system/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
    end

  end

  context 'S3 enabled' do

    before do
      S3[:enabled] = true
      ENV.stub(:[])
    end

    it "should create links to images on the S3 host" do
      bucket_name = "bucket"
      bucket_host = "#{bucket_name}.s3.amazonaws.com"
      ENV.stub(:[]).with("S3_BUCKET_NAME").and_return(bucket_name)
      AppConstants.load!

      helper.image_url(@image, :thumbnail).should eql("https://#{bucket_host}/#{@image.movement_slug}_image_#{@image.id}_thumbnail.jpg")
      helper.image_url(@image).should eql("https://#{bucket_host}/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
    end

    context 'CDN enabled' do

      it "should create links to images on the CDN host" do
        cdn_host = "cdn.cloudfront.net"
        ENV.stub(:[]).with("CDN_HOST").and_return(cdn_host)
        AppConstants.load!

        helper.image_url(@image, :thumbnail).should eql("https://#{cdn_host}/#{@image.movement_slug}_image_#{@image.id}_thumbnail.jpg")
        helper.image_url(@image).should eql("https://#{cdn_host}/#{@image.movement_slug}_image_#{@image.id}_original.jpg")
      end

    end

  end

end
