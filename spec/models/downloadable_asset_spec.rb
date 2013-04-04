# == Schema Information
#
# Table name: downloadable_assets
#
#  id                 :integer          not null, primary key
#  asset_file_name    :string(255)
#  asset_content_type :string(128)
#  asset_file_size    :integer
#  link_text          :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by         :string(255)
#  updated_by         :string(255)
#  movement_id        :integer
#

require "spec_helper"

describe DownloadableAsset do

end
