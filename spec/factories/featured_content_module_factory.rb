# == Schema Information
#
# Table name: featured_content_modules
#
#  id                             :integer          not null, primary key
#  featured_content_collection_id :integer
#  language_id                    :integer
#  title                          :text
#  image                          :string(255)
#  description                    :text
#  url                            :string(255)
#  button_text                    :string(255)
#  date                           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  position                       :integer
#

FactoryGirl.define do
  factory :featured_content_module do
    title         'title'
    url           'url'
    button_text   'button_text'
    language      { Language.find_by_name("English") || FactoryGirl.create(:english) }
    association   :featured_content_collection
  end
end
