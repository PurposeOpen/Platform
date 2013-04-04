class SetJoinModuleOnHomepageJoins < ActiveRecord::Migration
  def up
    Movement.all.each do |movement|
      UserActivityEvent.connection.execute <<-SQL
        update user_activity_events uae
        set content_module_id = (
          select cm.id from content_modules cm
          inner join content_module_links cml on cml.content_module_id = cm.id
          inner join pages p on cml.page_id = p.id
          inner join action_sequences aseq on p.action_sequence_id = aseq.id
          inner join campaigns c on aseq.campaign_id = c.id
          where p.name = 'Join'
          AND cm.type = 'JoinModule'
          AND c.movement_id = #{movement.id}
          AND cm.language_id = (select language_id from users u where u.id = uae.user_id)),
        content_module_type = 'JoinModule'
        where uae.activity = 'subscribed'
        AND uae.content_module_id IS NULL
        AND uae.movement_id = #{movement.id}
SQL
    end
  end

  def down
    # Can no longer distinguish homepage joins from join page joins
  end
end

# select cm.id from content_modules cm
# inner join content_module_links cml on cml.content_module_id = cm.id
# inner join pages p on cml.page_id = p.id
# inner join action_sequences aseq on p.action_sequence_id = aseq.id
# inner join campaigns c on aseq.campaign_id = c.id
# where p.name = 'Join'
# AND cm.type = 'JoinModule'
# AND c.movement_id = 11
# AND cm.language_id = (select language_id from users u where u.id = uae.user_id))
