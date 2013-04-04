# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

class UnsubscribeModule < ContentModule
  placeable_in MAIN, SIDEBAR
  option_fields :button_text, :email_label_text

  def needs_title?
    false
  end

  def shows_activity_stream?
    false
  end

  def subscribes_user_on_action?
    false
  end

  def can_remove_from_page?
    false
  end

  def requires_user_details?
    false
  end

  def take_action(user, action_info, page)
    user.unsubscribe!(action_info[:email])
  end
end
