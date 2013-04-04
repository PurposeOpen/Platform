module Admin::PushesHelper
  def link_to_create_or_update(blast, html_opts={})
    movement = blast.push.campaign.movement
    path = blast.list ? admin_movement_list_cutter_edit_path(:movement_id => movement, :list_id => blast.list) : admin_movement_list_cutter_new_path(:movement_id => movement, :blast_id => blast)
    link_to "Recipients", path, html_opts
  end

  def member_count(blast)
    if blast.list && ( count = blast.list.user_count )
      "(" + pluralize(count, "member") + ")"
    else
      ""
    end
  end

  def email_stat(metric, email_id)
    UserActivityEvent.send(metric).where(:email_id => email_id).count
  end
  
  def blast_sent_count(blast)
    blast.latest_sent_user_count
  end

  def blast_has_unsent_users(blast)
    blast.latest_unsent_user_count > 0
  end

  def last_updated_at_msg(date)
    date.nil? ? "Stats haven't been updated yet" : "Last updated #{time_ago_in_words(date)}"
  end
end
