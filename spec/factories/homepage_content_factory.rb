# == Schema Information
#
# Table name: homepage_contents
#
#  id            :integer          not null, primary key
#  banner_image  :string(255)
#  banner_text   :string(255)
#  updated_at    :datetime
#  updated_by    :string(255)
#  join_headline :string(255)
#  join_message  :string(255)
#  follow_links  :text
#  header_navbar :text
#  footer_navbar :text
#  homepage_id   :integer
#  language_id   :integer
#

FactoryGirl.define do
  factory :homepage_content do
    banner_text          "have joined"
    banner_image         "test.png"
    join_headline        "Join Headline"
    join_message         "Join Message"
    follow_links         Hash.new
    association         :language
    after(:create) do |content|
      content.homepage = FactoryGirl.create(:movement).homepage
    end
  end
end
