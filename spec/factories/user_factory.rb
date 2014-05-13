# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      not null
#  first_name               :string(64)
#  last_name                :string(64)
#  mobile_number            :string(32)
#  home_number              :string(32)
#  street_address           :string(128)
#  suburb                   :string(64)
#  country_iso              :string(2)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  is_member                :boolean          default(TRUE), not null
#  encrypted_password       :string(255)      default("!K1T7en$!!2011G")
#  password_salt            :string(255)
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  deleted_at               :datetime
#  is_admin                 :boolean          default(FALSE)
#  created_by               :string(255)
#  updated_by               :string(255)
#  is_volunteer             :boolean          default(FALSE)
#  movement_id              :integer          not null
#  language_id              :integer
#  postcode                 :string(255)
#  join_email_sent          :boolean
#  name_safe                :boolean
#  source                   :string(255)
#  permanently_unsubscribed :boolean
#  state                    :string(64)
#  lat                      :string(255)
#  lng                      :string(255)
#  time_zone                :string(255)
#

require Rails.root.join('spec', 'support', 'test_geolocation_service')
FactoryGirl.define do
  factory :user do
    email           { FactoryGirl.generate(:email) }
    updated_at      { FactoryGirl.generate(:time) }
    created_at      { FactoryGirl.generate(:time) }
    association     :language
    association     :movement
    source          :movement
    geolocation_service { |user| TestGeolocationService.new(user) }
  end

  factory :leo, parent: :user do
    email       "leonardo@borges.com"
    country_iso "BR"
    postcode    "9999"
    is_member   true
  end

  factory :brazilian_dude, parent: :user do
    email         "another@dude.com"
    country_iso   "BR"
    is_member     true
    postcode      "9999"
    first_name    "Joao"
    last_name     "Silva"
  end

  factory :brazilian_chick, parent: :user do
    email         "another@chick.com"
    country_iso   "BR"
    is_member     true
    postcode      "9999"
    first_name    "Jackie"
    last_name     "Tequila"
  end

  factory :aussie, parent: :user do
    email         "aussie@dude.com"
    country_iso   "AU"
    is_member     true
    postcode      "2000"
    first_name    "Peter"
    last_name     "Venkman"
  end

  factory :aussie_in_edgewater, parent: :user do
    email         "aussie_edgewater@dude.com"
    country_iso   "AU"
    is_member     true
    postcode      "6027"
  end

  factory :admin_user, parent: :user do
    is_admin      true
  end

  factory :user_with_profane_name, parent: :user do
    first_name    'Mierda'
    last_name     'Jones'
  end
end
