# == Schema Information
#
# Table name: platform_users
#
#  id                     :integer          not null, primary key
#  email                  :string(256)      not null
#  first_name             :string(64)
#  last_name              :string(64)
#  mobile_number          :string(32)
#  home_number            :string(32)
#  encrypted_password     :string(255)
#  password_salt          :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  is_admin               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

FactoryGirl.define do
  factory :platform_user do
    email           { generate(:email) }
    updated_at      { generate(:time) }
    created_at      { generate(:time) }
  end

  factory :admin_platform_user, parent: :platform_user do 
    is_admin true
  end
end
