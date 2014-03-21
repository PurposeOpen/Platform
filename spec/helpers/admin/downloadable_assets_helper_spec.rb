require "spec_helper"

describe Admin::DownloadableAssetsHelper do

  before do
    @asset = DownloadableAsset.create(
      :id => 123, 
      :asset => File.new(Rails.root + 'spec/fixtures/images/wikileaks.jpg'),
      :movement => FactoryGirl.create(:movement)
    )
  end

  context 'S3 disabled' do

    it "should create links to assets stored on the app host" do
      S3[:enabled] = false

      helper.download_asset_link(@asset).should match("/system/#{@asset.movement_slug}-#{@asset.id}-wikileaks.jpg")
    end

  end

  context 'S3 enabled' do

    before do
      S3[:enabled] = true
      ENV.stub(:[])
    end

    it "should create links to assets on the S3 host" do
      bucket_name = "bucket"
      bucket_host = "#{bucket_name}.s3.amazonaws.com"
      ENV.stub(:[]).with("S3_BUCKET_NAME").and_return(bucket_name)
      AppConstants.load!

      helper.download_asset_link(@asset).should match("#{bucket_host}/#{@asset.movement_slug}-#{@asset.id}-wikileaks.jpg")
    end

    context 'CDN enabled' do

      it "should create links to assets on the CDN host" do
        cdn_host = "cdn.cloudfront.net"
        ENV.stub(:[]).with("CDN_HOST").and_return(cdn_host)
        AppConstants.load!

        helper.download_asset_link(@asset).should match("#{cdn_host}/#{@asset.movement_slug}-#{@asset.id}-wikileaks.jpg")
      end

    end

  end

end
