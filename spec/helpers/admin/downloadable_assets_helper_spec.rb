require "spec_helper"

describe Admin::DownloadableAssetsHelper do
  before do
    @asset = DownloadableAsset.create(
      :id => 123, 
      :asset => File.new(Rails.root + 'spec/fixtures/images/wikileaks.jpg'),
      :movement => FactoryGirl.create(:movement)
    )
  end

  it "translates local paths to URLs" do
    S3[:enabled] = false
    helper.download_asset_link(@asset).should match("/system/#{@asset.movement_slug}-#{@asset.id}-wikileaks.jpg")
  end

  it "translates CDN paths to correct URLs" do
    Rails.application.config.action_controller.asset_host = "http://xyz.s3.amazonaws.com"
    S3[:enabled] = true
    S3[:bucket] = "xyz"
    helper.download_asset_link(@asset).should match("//xyz.s3.amazonaws.com/#{@asset.movement_slug}-#{@asset.id}-wikileaks.jpg")
  end
end
