# == Schema Information
#
# Table name: user_affiliations
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  movement_id :integer
#  role        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "spec_helper"

describe UserAffiliation do

  it "should return true if the user affiliation is an admin role" do
    user_affiliation = build(:user_affiliation, role: UserAffiliation::ADMIN)
    user_affiliation.should be_admin
    user_affiliation.should_not be_campaigner
    user_affiliation.should_not be_campaigner_senior
    user_affiliation.should be_is_admin
    user_affiliation.should_not be_is_campaigner
    user_affiliation.should_not be_is_campaigner_senior
  end

  it "should return true if the user affiliation is an campaigner role" do
    user_affiliation = build(:user_affiliation, role: UserAffiliation::CAMPAIGNER)
    user_affiliation.should_not be_admin
    user_affiliation.should be_campaigner
    user_affiliation.should_not be_campaigner_senior
    user_affiliation.should be_is_campaigner
    user_affiliation.should_not be_is_admin
    user_affiliation.should_not be_is_campaigner_senior
  end

  it "should return true if the user affiliation is an senior campaigner role" do
    user_affiliation = build(:user_affiliation, role: UserAffiliation::SENIOR_CAMPAIGNER)
    user_affiliation.should_not be_admin
    user_affiliation.should_not be_campaigner
    user_affiliation.should be_campaigner_senior
    user_affiliation.should_not be_is_campaigner
    user_affiliation.should_not be_is_admin
    user_affiliation.should be_is_campaigner_senior
  end

  it "should return options for the roles select field" do
    UserAffiliation.roles_options_for_select.should ==  [["Admin", "admin"], ["Campaigner", "campaigner"], ["Senior Campaigner", "campaigner_senior"]]
  end

end
