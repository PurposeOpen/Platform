class RenameContentPagesTableToPages < ActiveRecord::Migration
  def up
    rename_column :user_activity_events, :content_page_id, :page_id
    rename_column :content_module_links, :content_page_id, :page_id
    rename_column :donations, :content_page_id, :page_id
    rename_column :petition_signatures, :content_page_id, :page_id
    rename_column :user_calls, :content_page_id, :page_id
    rename_column :user_emails, :content_page_id, :page_id
    rename_table :content_pages, :pages
  end

  def down
    rename_table :pages, :content_pages
    rename_column :user_activity_events, :page_id, :content_page_id
    rename_column :content_module_links, :page_id, :content_page_id
    rename_column :donations, :page_id, :content_page_id
    rename_column :petition_signatures, :page_id, :content_page_id
    rename_column :user_calls, :page_id, :content_page_id
    rename_column :user_emails, :page_id, :content_page_id
  end
end
