FactoryGirl.define do
  factory :petition_signature do
    user
    action_page
    content_module :factory => :petition_module
  end

  factory :user_email do
    user           { create(:user) }
    action_page    { create(:action_page) }
    content_module { create(:email_targets_module) }
    subject        "The Subject"
    body           "The Body"
    targets        "person1@example.com, person2@example.com"
  end

  sequence :transaction_ids do |i|
    "transaction#{i}"
  end

  sequence :subscription_ids do |i|
    "subscription#{i}"
  end

  factory :donation do
    user              { create(:user) }
    action_page       { create(:action_page) }
    content_module    { create(:donation_module) }
    currency          :usd
    amount_in_cents   1000
    payment_method    "credit_card"
    frequency         "one_off"
    transaction_id    { generate(:transaction_ids)}
  end

  factory :donation_without_validation, :parent => :donation do
    to_create do |instance|
      instance.save(:validate => false)
    end
  end
  
  factory :recurring_donation, :parent => :donation do
    frequency "weekly"
    subscription_id { generate(:subscription_ids) }
  end

  factory :flagged_donation, :parent => :recurring_donation do
    flagged_since   { Time.now }
    flagged_because "Y U NO PAY US"
  end
  
  factory :paypal_donation, :class => Donation do
    user              { create(:user) }
    action_page       { create(:action_page) }
    content_module    { create(:donation_module) }
    currency          :usd
    amount_in_cents   1000
    payment_method    "paypal"
    frequency         "one_off"
  end

  factory :transaction do
    donation        { create(:donation) }
    amount_in_cents 1000
    successful      true
  end

  factory :failed_transaction, :class => Transaction do
    donation        { create(:donation) }
    amount_in_cents 1000
    successful      false
  end
end

