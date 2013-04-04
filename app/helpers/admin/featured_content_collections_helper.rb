module Admin::FeaturedContentCollectionsHelper
  def add_featured_content_module_link(movement, collection, text)
    link_to(text, admin_movement_featured_content_modules_path(movement, :featured_content_collection_id => collection.id), :method => :post, :remote => true, :class => "button add-module-link")
  end

  def remove_featured_content_module_link(movement, featured_content_module)
    link_to "", admin_movement_featured_content_module_path(movement, featured_content_module.id), :remote => true, :method => :delete, :confirm => "Remove featured content?\n\nThis cannot be undone.", :class => "remove_module ui-icon ui-icon-closethick", :title => "Remove"
  end

  def action_pages_tree_json(movement, featured_content_collection)
    Campaign.includes(:action_sequences => :action_pages).where(:movement_id => movement.id).order('updated_at DESC').collect do |campaign|
      {
          "data" => campaign.name,
          "children" => campaign.action_sequences.collect do |action_sequence|
            {"data" => action_sequence.name,
             "children" => action_sequence.action_pages.collect do |action_page|
               {"data" => action_page.name,
                "metadata" => {"url" => admin_movement_featured_content_modules_path(movement, :featured_content_collection_id => featured_content_collection.id, :action_page_id => action_page.id)}
               }
             end
            }
          end
      }
    end.to_json
  end

end
