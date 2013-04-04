require "spec_helper"

describe Admin::FeaturedContentCollectionsHelper do
  describe "action_pages_tree_json" do
    it "should return campaigns with action_sequences and action_pages" do
      featured_content_collection = create(:featured_content_collection)
      movement_1 = create(:movement)
      campaign_1 = create(:campaign, movement: movement_1)
      action_sequence = create(:action_sequence, campaign: campaign_1)
      action_page_1 = create(:action_page, action_sequence: action_sequence)
      action_page_2 = create(:action_page, action_sequence: action_sequence)
      action_page_1_url = admin_movement_featured_content_modules_path(movement_1, featured_content_collection_id: featured_content_collection.id,
                                                                       action_page_id: action_page_1.id)
      action_page_2_url = admin_movement_featured_content_modules_path(movement_1, featured_content_collection_id: featured_content_collection.id,
                                                                       action_page_id: action_page_2.id)

      movement_2 = create(:movement)
      create(:campaign, movement: movement_2)

      action_pages_tree_json(movement_1, featured_content_collection).should == [{
          "data" => campaign_1.name,
          "children" => [
              {"data" => action_sequence.name,
               "children" => [
                   {"data" => action_page_1.name,
                    "metadata" => {"url" => action_page_1_url}
                   },
                   {"data" => action_page_2.name,
                    "metadata" => {"url" => action_page_2_url}
                   }
               ]
              }
          ]
      }].to_json
    end

    it "should return campaigns with no action sequence" do
      featured_content_collection = create(:featured_content_collection)
      movement = create(:movement)
      campaign = create(:campaign, movement: movement)
      action_pages_tree_json(movement, featured_content_collection).should == [{"data" => campaign.name, "children" => []}].to_json
    end

    it "should return campaigns in descending order of updated_at" do
      featured_content_collection = create(:featured_content_collection)
      movement = create(:movement)
      campaign_updated_first = create(:campaign, movement: movement, :updated_at => 10.minutes.ago)
      campaign_updated_last = create(:campaign, movement: movement, :updated_at => 1.minute.ago)
      action_pages_tree_json(movement, featured_content_collection).should == [{"data" => campaign_updated_last.name, "children" => []},
                                                                               {"data" => campaign_updated_first.name, "children" => []}].to_json
    end
  end
end
