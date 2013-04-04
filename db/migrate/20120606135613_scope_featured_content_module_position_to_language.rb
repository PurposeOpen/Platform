class ScopeFeaturedContentModulePositionToLanguage < ActiveRecord::Migration
  def up
    FeaturedContentCollection.includes(:featured_content_modules).all.each do |collection|
      modules_by_language = collection.featured_content_modules.group_by { |content| content.language }
      modules_by_language.each_key do |language|
        position = 0
        modules_by_language[language].each do |content|
          content.position = position
          position += 1
          content.save!(:validate => false)
        end
      end
    end
  end

  def down
  end
end
