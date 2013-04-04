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

FactoryGirl.define do
  factory :image do
    image_file_name    "spec/fixtures/images/wikileaks.jpg"
    image_content_type "image/jpeg"
    image_file_size    28432
  end
end
