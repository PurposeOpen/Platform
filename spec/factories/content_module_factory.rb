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

FactoryGirl.define do
  # abstract, general content module factory
  # (don't use directly)
  factory :content_module do
    updated_at { generate(:time) }
    created_at { generate(:time) }
    language   { Language.find_by_iso_code("en") || create(:english) }
  end

  factory :html_module, parent: :content_module, class: HtmlModule do
    type    HtmlModule.name
    content "<p>Lorem ipsum dolor sit amet</p>" * 5
    title   "Lorem Ipsum"
  end

  factory :accordion_module, parent: :content_module, class: AccordionModule do
    type       AccordionModule.name
    content    "<p>Lorem ipsum dolor sit amet</p>" * 5
    title      "Lorem Ipsum"
  end

  factory :html_module_with_image, parent: :content_module, class: HtmlModule do
    type       HtmlModule.name
    content    "<p>Lorem ipsum dolor sit amet</p><img src='/whatever/module_img.png'"
    title      "Lorem Ipsum"
  end

  factory :past_campaign_module, parent: :content_module, class: PastCampaignModule do
    type       PastCampaignModule.name
    content    "<p>Lorem ipsum dolor sit amet</p>" * 5
    title      "Lorem Ipsum"
  end

  factory :petition_module, parent: :content_module, class: PetitionModule do
    type                  PetitionModule.name
    signatures_goal       10_000
    thermometer_threshold 500
    button_text          'Sign the petition!'
    content              "<p>Lorem ipsum dolor sit amet</p>" * 5
    title                "Lorem Ipsum"
    petition_statement   "We want stuff"
    comment_label        "Comment label"
    comment_text         "Comment text"
  end

  factory :join_module, parent: :content_module, class: JoinModule do
    type                     JoinModule.name
    button_text              'Join the movement!'
    content                  "<p>Lorem ipsum dolor sit amet</p>" * 5
    title                    "Lorem Ipsum"
    join_statement           "We want stuff"
    post_join_title          "Post join title"
    post_join_join_statement "Post join join statement"
    post_join_content        "Post join content"
    post_join_button_text    "Post join button text"
    comment_label        "Comment label"
    comment_text         "Comment text"
  end

  factory :email_targets_module, parent: :content_module, class: EmailTargetsModule do
    type             EmailTargetsModule.name
    default_body     "<p>Lorem ipsum dolor sit amet</p>" * 5
    default_subject  "This is the default subject line"
    targets          "'email11' <email11@yourdomain.org>, 'email22' <email22@yourdomain.org>, 'email33' <email33@yourdomain.org>"
    button_text      "Send your email!"
    content          "<p>Lorem ipsum dolor sit amet</p>" * 5
    title            "Lorem Ipsum"
    emails_goal      100
    thermometer_threshold 10
  end

  factory :donation_module, parent: :content_module, class: DonationModule do
    type                  DonationModule.name
    content               "<p>Lorem ipsum dolor sit amet</p>" * 5
    title                 "Lorem Ipsum"
    thermometer_threshold 1000
    default_currency      "usd"
  end

  factory :tax_deductible_donation_module, parent: :donation_module, class: TaxDeductibleDonationModule do
  end

  factory :non_tax_deductible_donation_module, parent: :donation_module, class: NonTaxDeductibleDonationModule do
  end

  factory :tell_a_friend_module, parent: :content_module, class: TellAFriendModule do
    type          TellAFriendModule.name
    headline      'Thank you!'
    message       'Your act of sharing is much appreciated.'
    email_subject 'This is the email subject'
    email_body    'This is the email message'
    tweet         'Some Tweet'
    share_url     'http://this.is.a.share_url'
    facebook_image_url 'http://this.is.facebook_image_url'
  end

  factory :unsubscribe_module, parent: :content_module, class: UnsubscribeModule do
    type          UnsubscribeModule.name
    button_text   'Free me!'
  end

  class DummyModule < ContentModule
    option_fields :foo, :bar
    def take_action; true; end
  end

  factory :dummy_module, parent: :content_module, class: DummyModule do
    type    DummyModule.name
    content "<p>Lorem ipsum dolor sit amet</p>" * 5
    title   "Lorem Ipsum"
  end
end
