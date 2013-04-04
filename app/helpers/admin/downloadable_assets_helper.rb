module Admin
  module DownloadableAssetsHelper
    def download_asset_link(asset)
      url = S3[:enabled] ? "#{AppConstants.s3_bucket_uri}/#{asset.name}" :
          "/system/#{asset.name}"
      link_to(asset.link_text, url)
    end
  end
end