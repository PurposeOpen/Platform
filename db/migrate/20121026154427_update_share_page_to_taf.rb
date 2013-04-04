class Share < ActiveRecord::Base; end

class UpdateSharePageToTaf < ActiveRecord::Migration
  def up
  	execute 'DROP TEMPORARY TABLE IF EXISTS pages_without_taf_module'
    
    execute <<-SQL
      CREATE TEMPORARY TABLE pages_without_taf_module AS 
        SELECT id FROM pages WHERE `type` = 'ActionPage' AND 
          id NOT IN 
            (SELECT DISTINCT p.id
            FROM pages p
            INNER JOIN content_module_links cml ON cml.page_id = p.id
            INNER JOIN content_modules cm ON cm.id = cml.content_module_id
            WHERE p.`type` = 'ActionPage' AND cm.`type` = 'TellAFriendModule')
      SQL

    execute 'DROP TEMPORARY TABLE IF EXISTS shares_to_update'
    execute <<-SQL
      CREATE TEMPORARY TABLE shares_to_update (UNIQUE(share_id)) AS
        SELECT shares.id AS share_id,
          (SELECT 
            (SELECT cml.page_id 
            FROM pages p2 
            INNER JOIN content_module_links cml ON cml.page_id = p2.id 
            INNER JOIN content_modules cm ON cm.id = cml.content_module_id 
            WHERE cm.`type` = 'TellAFriendModule' AND p.action_sequence_id = p2.action_sequence_id 
            LIMIT 1)
          FROM shares s2
          INNER JOIN pages p ON p.id = s2.page_id
          WHERE s2.id = shares.id)  AS new_page_id
        FROM shares
        WHERE shares.page_id IN (SELECT id from pages_without_taf_module)
    SQL

    execute <<-SQL
      UPDATE shares
        SET shares.page_id = IFNULL((SELECT new_page_id FROM shares_to_update WHERE shares_to_update.share_id = shares.id), shares.page_id)
    SQL

    execute 'DROP TEMPORARY TABLE IF EXISTS shares_to_update'
    execute 'DROP TEMPORARY TABLE IF EXISTS pages_without_taf_module'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
