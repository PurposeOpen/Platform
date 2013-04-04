class AddCrowdringCampaignNameToActionPage < ActiveRecord::Migration
  def change
    add_column(:pages, :crowdring_campaign_name, :string)
  end
end
