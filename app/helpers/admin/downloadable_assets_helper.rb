module Admin
  module DownloadableAssetsHelper
    def download_asset_link(asset)
      url = S3[:enabled] ? "#{AppConstants.uploaded_asset_host}/#{asset.name}" :
          "/system/#{asset.name}"
      link_to(asset.link_text, url)
    end
  end
end