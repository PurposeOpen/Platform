# == Schema Information
#
# Table name: featured_content_collections
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  featurable_id   :integer
#  featurable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe FeaturedContentCollection do

  it 'should return featured content modules for a language' do
    french = FactoryGirl.create(:french)
    spanish = FactoryGirl.create(:spanish)
    fr_featured_content_module = FactoryGirl.create(:featured_content_module, language: french)
    featured_content_collection = fr_featured_content_module.featured_content_collection
    fr_featured_content_module2 = FactoryGirl.create(:featured_content_module, language: french, featured_content_collection: featured_content_collection)
    FactoryGirl.create(:featured_content_module, language: spanish, featured_content_collection: featured_content_collection)

    french_module = featured_content_collection.modules_for_language(french)
    french_module.should match_array([fr_featured_content_module, fr_featured_content_module2])
  end

  it 'should return only valid featured content modules for a given language' do
    french = FactoryGirl.create(:french)
    carousel = FactoryGirl.create(:featured_content_collection, name: 'Carousel')
    fr_featured_content_module = FactoryGirl.create(:featured_content_module, language: french, featured_content_collection: carousel)
    fr_featured_content_module2 = FactoryGirl.build(:featured_content_module, language: french, featured_content_collection: carousel, title: nil)
    fr_featured_content_module2.save!(validate: false)

    french_modules = carousel.valid_modules_for_language(french)
    french_modules.should match_array([fr_featured_content_module])
  end

  it 'should tell that all modules are valid when so they are' do
    lang = FactoryGirl.create(:language)
    carousel = FactoryGirl.create(:featured_content_collection, name: 'Carousel')
    module_1 = FactoryGirl.create(:featured_content_module, language: lang, featured_content_collection: carousel)
    module_2 = FactoryGirl.create(:featured_content_module, language: lang, featured_content_collection: carousel)

    carousel.all_modules_valid?(lang).should be_true
  end

  it 'should tell when there are invalid modules for a language' do
    english = FactoryGirl.create(:language)
    portuguese = FactoryGirl.create(:language)
    carousel = FactoryGirl.create(:featured_content_collection, name: 'Carousel')
    portuguese_module = FactoryGirl.create(:featured_content_module, language: portuguese, featured_content_collection: carousel)
    english_module_1 = FactoryGirl.create(:featured_content_module, language: english, featured_content_collection: carousel)
    english_module_2 = FactoryGirl.build(:featured_content_module, language: english, featured_content_collection: carousel, title: nil)
    english_module_2.save!(validate: false)

    english_module_2.should be_valid
    english_module_2.should_not be_valid_with_warnings
    carousel.all_modules_valid?(english).should be_false
    carousel.all_modules_valid?(portuguese).should be_true
  end
end
