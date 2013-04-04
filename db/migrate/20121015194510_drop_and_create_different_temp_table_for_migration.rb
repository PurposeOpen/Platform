class DropAndCreateDifferentTempTableForMigration < ActiveRecord::Migration
  def up
    drop_table :temp_AOAK_user_xref

    execute <<-SQL
      CREATE TABLE `temp_AOAK_user_xref` (
        `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
        `ao_user_id` int(11) DEFAULT NULL,
        `ak_user_id` int(11) DEFAULT NULL,
        `user_id` int(11) DEFAULT NULL,
        `user_language` int(11) DEFAULT NULL,
        `member_created` datetime DEFAULT NULL,
        `subscription_created` datetime DEFAULT NULL,
        KEY `idx_AO_ID` (`ao_user_id`),
        KEY `idx_AK_ID` (`ak_user_id`),
        KEY `idx_user_ID` (`user_id`),
        KEY `idx_email` (`email`)  ) ;
    SQL
  end

  def down
    drop_table :temp_AOAK_user_xref

    execute <<-SQL
      CREATE TABLE `temp_AOAK_user_xref` (
        `ao_user_id` int(11),
        `ak_user_id` int(11),
        `user_id` int(11),
        `user_language` int(11),
        member_created datetime,
        subscription_created datetime  ) ;
    SQL
  end
end
