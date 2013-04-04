class AddMigrationTables < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE `temp_AOAK_user_xref` (
        `ao_user_id` int(11),
        `ak_user_id` int(11),
        `user_id` int(11),
        `user_language` int(11),
        member_created datetime,
        subscription_created datetime  ) ;
    SQL

    execute <<-SQL
      ALTER TABLE emails ADD COLUMN alternate_key_a VARCHAR(25);
    SQL

    execute <<-SQL
      ALTER TABLE emails ADD COLUMN alternate_key_b VARCHAR(25);
    SQL

    execute <<-SQL
      CREATE TABLE `temp_AK_mailing_xref` (
        `ak_mail_id` int(11) NOT NULL,
        `ak_subj_id` int(11) NOT NULL,
        `platform_mail_id` int(11) NOT NULL ) ;
    SQL

    execute <<-SQL
      CREATE TABLE `temp_AK_usermailing` (
        `id` int(11) NOT NULL,
        `mailing_id` int(11) NOT NULL,
        `user_id` int(11) NOT NULL,
        `subject_id` int(11) DEFAULT NULL,
        `created_at` datetime NOT NULL,
        COMPLETED_AT datetime,
        PRIMARY KEY (`id`),
        UNIQUE KEY `mailing_id` (`mailing_id`,`user_id`),
        KEY `core_usermailing_mailing_id` (`mailing_id`),
        KEY `core_usermailing_user_id` (`user_id`),
        KEY `core_usermailing_subject_id` (`subject_id`),
        KEY `core_usermailing_created_at` (`created_at`)  ) ;
    SQL

    execute <<-SQL
      CREATE TABLE `temp_AK_open` (
        `user_id` int(11) DEFAULT NULL,
        `mailing_id` int(11) DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        COMPLETED_AT datetime,
        KEY `user_id` (`user_id`),
        KEY `mailing_id` (`mailing_id`,`user_id`)  ) ;
    SQL

    execute <<-SQL
      CREATE TABLE `temp_AK_click` (
        `clickurl_id` int(11) NOT NULL,
        `user_id` int(11) DEFAULT NULL,
        `mailing_id` int(11) DEFAULT NULL,
        `link_number` int(11) DEFAULT NULL,
        `source` varchar(255) DEFAULT NULL,
        `referring_user_id` int(11) DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        COMPLETED_AT datetime,
        KEY `user_id` (`user_id`),
        KEY `source` (`source`),
        KEY `clickurl_id` (`clickurl_id`),
        KEY `mailing_id` (`mailing_id`,`user_id`)   ) ;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE `temp_AOAK_user_xref`;
    SQL

    execute <<-SQL
      ALTER TABLE emails DROP COLUMN alternate_key_a;
    SQL

    execute <<-SQL
      ALTER TABLE emails DROP COLUMN alternate_key_b;
    SQL

    execute <<-SQL
      DROP TABLE `temp_AK_mailing_xref`;
    SQL

    execute <<-SQL
      DROP TABLE `temp_AK_usermailing`;
    SQL

    execute <<-SQL
      DROP TABLE `temp_AK_open`;
    SQL

    execute <<-SQL
      DROP TABLE `temp_AK_click`;
    SQL
  end
end
