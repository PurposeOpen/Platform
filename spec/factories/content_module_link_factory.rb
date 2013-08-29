# == Schema Information
#
# Table name: content_module_links
#
#  id                :integer          not null, primary key
#  page_id           :integer          not null
#  content_module_id :integer          not null
#  position          :integer
#  layout_container  :string(64)
#

FactoryGirl.define do
  #do not use directly
  factory :content_module_link do
    association :page, :factory => :action_page
    association :content_module, :factory => :html_module
    layout_container ContentModule::MAIN
    after(:create) do |l|
      l.page.content_module_links << l
    end
  end

  factory :header_module_link, :parent => :content_module_link do
    layout_container :header_content
  end

  factory :sidebar_module_link, :parent => :content_module_link do
    layout_container :sidebar
  end

  factory :main_module_link, :parent => :content_module_link do
    layout_container :main_content
  end

  factory :taf_module_link, :parent => :content_module_link do
    layout_container :sidebar
    association :content_module, :factory => :tell_a_friend_module
  end
end
