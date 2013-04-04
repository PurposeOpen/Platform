class UpdateSeniorCampaignerToCampaignerForAllOut < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("update user_affiliations set role = 'campaigner' where role = 'campaigner_senior' and movement_id = (select id from movements where name = 'All Out')")
  end

  def down
    ActiveRecord::Base.connection.execute("update user_affiliations set role = 'campaigner_senior' where role = 'campaigner' and movement_id = (select id from movements where name = 'All Out')")
  end
end
