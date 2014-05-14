# == Schema Information
#
# Table name: emails
#
#  id                :integer          not null, primary key
#  blast_id          :integer
#  name              :string(255)
#  sent_to_users_ids :text
#  subject           :string(255)
#  body              :text
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  test_sent_at      :datetime
#  delayed_job_id    :integer
#  language_id       :integer
#  from              :string(255)
#  reply_to          :string(255)
#  alternate_key_a   :string(25)
#  alternate_key_b   :string(25)
#  sent              :boolean
#  sent_at           :datetime
#

FactoryGirl.define do
  factory :email do
    blast
    name              "Dummy Email Name"
    sent_to_users_ids ""
    from              "Your Name <from@yourdomain.org>"
    reply_to          "Your Name <reply_to@yourdomain.org>"
    subject           "Fwd: Fwd: Re: Fwd: LOL! Re: Funny cat pictures"
    body              "Look at these amusing cats!"
    language
  end

  factory :email_with_tokens, parent: :email do
    subject "<TEST>Yes, {NAME|Friend}, we can! "
    body    %{Dear {NAME|Friend}, I told you so! You live at {POSTCODE|Nowhere} and your email is {EMAIL|}. Pls click <a href="{MOVEMENT_URL|}/?t={TRACKING_HASH|NOT_AVAILABLE}">{MOVEMENT_URL|}</a>}.html_safe
  end

  factory :proofed_email, parent: :email do
    test_sent_at      Time.now - 1.day
  end
  
  factory :sent_email, parent: :email do 
    sent_at Time.now - 1.day 
  end
end
