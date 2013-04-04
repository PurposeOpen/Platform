# coding: utf-8
# == Schema Information
#
# Table name: languages
#
#  id          :integer          not null, primary key
#  iso_code    :string(255)
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  native_name :string(255)
#

FactoryGirl.define do
  letters = ("a".."z").to_a

  # this generates a max of 26 * 26 = 676 unique languages
  sequence :iso_code do |i|                  
    first, second = i.divmod 26
    [ letters[first], letters[second] ].join
  end

  sequence :language_name do |i|
    "Language #{i}"
  end

  factory :language do
    iso_code       { generate(:iso_code) }
    name           { generate(:language_name) }
    native_name    "tlhIngan Hol"
    updated_at     { generate(:time) }
    created_at     { generate(:time) }
  end

  factory :english, :parent => :language do |f|
    iso_code       "en"
    name           "English"
    native_name    "English"
  end

  factory :portuguese, :parent => :language do |f|
    iso_code       "pt"
    name           "Portuguese"
    native_name    "Português"
  end

  factory :french, :parent => :language do |f|
    iso_code       "fr"
    name           "French"
    native_name    "Français"
  end

  factory(:spanish, :parent => :language) do |f|
    iso_code       "es"
    name           "Spanish"
    native_name    "Español"
  end
end
