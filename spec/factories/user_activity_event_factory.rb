# == Schema Information
#
# Table name: user_activity_events
#
#  id                       :integer          not null, primary key
#  user_id                  :integer          not null
#  activity                 :string(64)       not null
#  campaign_id              :integer
#  action_sequence_id       :integer
#  page_id                  :integer
#  content_module_id        :integer
#  content_module_type      :string(64)
#  user_response_id         :integer
#  user_response_type       :string(64)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  donation_amount_in_cents :integer
#  donation_frequency       :string(255)
#  email_id                 :integer
#  push_id                  :integer
#  get_together_event_id    :integer
#  movement_id              :integer
#  comment                  :string(255)
#  comment_safe             :boolean
#

FactoryGirl.define do
  factory :activity, :class => UserActivityEvent do
    user     { create(:leo) }
    activity "action_taken"
  end

  factory :brazilian_activity, :class => UserActivityEvent do
    user     { create(:brazilian_dude) }
    activity "action_taken"
  end

  factory :leo_activity, :class => UserActivityEvent do
    user     { create(:leo) }
    activity "action_taken"
  end

  factory :aussie_activity, :class => UserActivityEvent do
    user     { create(:aussie) }
    activity "action_taken"
  end

  factory :aussie_recurring_activity, :class => UserActivityEvent do
    user               { create(:aussie) }
    activity           "action_taken"
    donation_frequency "weekly"
  end

  factory :leo_nonrecurring_activity, :class => UserActivityEvent do
    user               { create(:leo) }
    activity           "action_taken"
    donation_frequency "one_off"
  end

  factory :brazilian_nonrecurring_activity, :class => UserActivityEvent do
    user               { create(:brazilian_dude) }
    activity           "action_taken"
    donation_frequency "one_off"
  end

  factory :action_taken_activity, :class => UserActivityEvent do
    user         { create(:aussie) }
    activity     "action_taken"
    campaign     { create(:campaign, :movement => self.movement) }
    page  { create(:action_page, :action_sequence => create(:action_sequence, :campaign => self.campaign)) }
    movement { create(:movement) }
  end

  factory :subscribed_activity, :class => UserActivityEvent do
    user     { FactoryGirl.create(:leo) }
    activity "subscribed"
  end

  factory :email_sent_activity, :class => UserActivityEvent do
    user     { create(:leo) }
    activity "email_sent"
    push     { create(:email).blast.push }
  end

  factory :user_activity_event, :class => UserActivityEvent do
    user
  end
end
