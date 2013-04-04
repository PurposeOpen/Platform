class SetJoinPageOnHomepageSubscribeEvents < ActiveRecord::Migration
  def up
    Movement.all.each do |movement|
      join_page = movement.join_page rescue nil
      next unless join_page
      action_sequence = join_page.action_sequence
      campaign = action_sequence.campaign
      UserActivityEvent.where(movement_id: movement.id,
        activity: 'subscribed',
        page_id: nil,
        action_sequence_id: nil,
        campaign_id: nil
      ).update_all(
        page_id: join_page.id,
        action_sequence_id: action_sequence.id,
        campaign_id: campaign.id
      )
    end
  end

  def down
    Movement.all.each do |movement|
      join_page = movement.join_page rescue nil
      next unless join_page
      UserActivityEvent.where(movement_id: movement.id,
        activity: 'subscribed',
        content_module_id: nil
      ).update_all(
        page_id: nil,
        action_sequence_id: nil,
        campaign_id: nil
      )
    end
  end
end
