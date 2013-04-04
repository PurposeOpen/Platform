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

require File.join(Rails.root, 'lib', 'paperclip_processors', 'resizer')

class Image < ActiveRecord::Base

  SIZES = [
    ["Home page banner image (480x368)", "480x368"],
    ["Home page slideshow image (416x224)", "416x224"],
    ["Campaign page main/header image (528px wide)", "528x"],
    ["Campaign page sidebar image (304px wide)", "304x"],
    ["Full width image (873px wide)", "873x"], 
    ["Small photo (200px wide)", "200x"], 
    ["Medium photo (360px wide)", "360x"], 
    ["Custom", ""]
  ]

  FILE_TEMPLATE = ":movement_slug_image_:id_:style.:extension"

  ATTACHED_FILE_OPTS = {
    :default_style => :full,
    :whiny => true,
    :whiny_thumbnails => true,
    :styles => { 
      :thumbnail => "120x120>", 
      :full => { :processors => [:resizer] }
    }
  }

  def self.has_attached_file_via_s3
    has_attached_file :image, ATTACHED_FILE_OPTS.merge(
      :storage => :s3,
      :bucket => S3[:bucket],
      :path => FILE_TEMPLATE,
      :s3_credentials => {
        :access_key_id => S3[:key],
        :secret_access_key => S3[:secret]
      }
    )
  end

  def self.has_attached_file_via_filesystem
    has_attached_file :image, ATTACHED_FILE_OPTS.merge(
      :storage => :filesystem, 
      :path => Rails.root.join('public', 'system', FILE_TEMPLATE).to_s
    )
  end

  if S3[:enabled]
    has_attached_file_via_s3
  else
    has_attached_file_via_filesystem
  end

  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => /image\/\w+/
  validates_attachment_size :image, :less_than => 10.megabytes

  before_create :measure_dimensions

  attr_accessor :dimensions, :resize #, :height, :width

  acts_as_user_stampable

  searchable do
    time :created_at
    text :image_file_name, :as => :image_file_name_text_substring
    text :image_description, :as => :image_description_text_substring
    integer :movement_id
  end
  handle_asynchronously :solr_index

  belongs_to :movement

  def attachment?
    image? && 
      !image_file_name.blank? &&
      (S3[:enabled] || File.exists?(image.path(:thumbnail)))
  end

  def name(format = :original)
    "#{movement_slug}_image_#{id}_#{format.to_s}#{File.extname(image_file_name)}"
  end
  
  def movement_slug
    self.movement.friendly_id
  end

  private

  
  def measure_dimensions    
    if tmp_img = image.queued_for_write[:full]
      dimensions = Paperclip::Geometry.from_file(tmp_img)
      self.image_width = dimensions.width
      self.image_height = dimensions.height
    end
  end
end
