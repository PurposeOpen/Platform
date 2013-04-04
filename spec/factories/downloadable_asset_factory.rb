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

FactoryGirl.define do
  factory :downloadable_asset do
    asset_file_name    "my_document.doc"
    asset_content_type "text"
    asset_file_size    28432
    link_text          "some link text"
  end
end
