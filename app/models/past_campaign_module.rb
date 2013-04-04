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

class PastCampaignModule < ContentModule
  MAX_PAST_ACTIONS = 10
  for i in (1..MAX_PAST_ACTIONS)
    option_fields "action#{i}", "action#{i}_link"
  end  

  placeable_in MAIN
end
