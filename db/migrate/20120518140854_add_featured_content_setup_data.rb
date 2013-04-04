class Movement < ActiveRecord::Base; end
class Homepage < ActiveRecord::Base; end
class FeaturedContentCollection < ActiveRecord::Base; end

class AddFeaturedContentSetupData < ActiveRecord::Migration

  def up
    seed_homepage_collections_for('walk free', 'Carousel', 'Featured Actions')

    seed_homepage_collections_for('all out', 'Carousel', 'Featured Actions')
    seed_content_page_collections_for('all out', 'About', 'Press Releases')
  end

  def down
  end

  private

  def seed_homepage_collections_for(movement_name, *collection_names)
    movement = find_movement(movement_name)
    if (movement)
      featurable = Homepage.where(:movement_id => movement.id).first
      seed_collections_for(featurable, collection_names)
    end
  end

  def seed_content_page_collections_for(movement_name, page_name, *collection_names)
    movement = find_movement(movement_name)
    if (movement)
      featurable = ContentPage.joins(:content_page_collection).where(:name => page_name, :content_page_collections => {:movement_id => movement.id}).first
      seed_collections_for(featurable, collection_names)
    end
  end

  def find_movement(movement_name)
    Movement.where("name LIKE :name", {:name => movement_name}).first
  end

  def seed_collections_for(featurable, collection_names)
    collection_names.each do |collection_name|
      FeaturedContentCollection.seed_once(:name, :featurable_id, :featurable_type, {
          :name => collection_name,
          :featurable_id => featurable.id,
          :featurable_type => featurable.class.name
        }
      )
    end
  end
end
