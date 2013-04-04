class UpdateCampaignerRoleToSeniorCampaignerInUserAffiliations < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("update user_affiliations set role = 'campaigner_senior' where role='campaigner'")
  end

  def down
    ActiveRecord::Base.connection.execute("update user_affiliations set role = 'campaigner' where role='campaigner_senior'")
  end
end
