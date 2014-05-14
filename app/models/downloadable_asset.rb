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

class DownloadableAsset < ActiveRecord::Base
  validates_presence_of :link_text

  acts_as_user_stampable
  belongs_to :movement
    
  FILE_TEMPLATE = ":movement_slug-:id-:filename"

  def self.has_attached_file_via_s3
    has_attached_file :asset, 
      storage: :s3,
      whiny: true,
      bucket: S3[:bucket],
      storage: :s3,
      path: FILE_TEMPLATE,
      s3_credentials: {
        access_key_id: S3[:key],
        secret_access_key: S3[:secret]
      }
  end

  def self.has_attached_file_via_filesystem
    has_attached_file :asset,
      storage: :filesystem,
      whiny: true,
      path: Rails.root.join('public', 'system', FILE_TEMPLATE).to_s
  end

  if S3[:enabled]
    has_attached_file_via_s3
  else
    has_attached_file_via_filesystem
  end

  validates_attachment_presence :asset

  searchable do
    time :created_at
    text :asset_file_name, as: :asset_file_name_text_substring
    text :link_text, as: :link_text_text_substring
    integer :movement_id
  end
  handle_asynchronously :solr_index

  def attachment?
    asset? && !asset_file_name.blank? && (S3[:enabled] || File.exists?(asset.path))
  end

  def name
    "#{movement_slug}-#{id}-#{asset_file_name}"
  end
  
  def kilobytes
    asset_file_size / 1024
  end

  def movement_slug
    self.movement.friendly_id
  end
end
