class AddTextToEmailFooterAndRenameContentToHtml < ActiveRecord::Migration
  def change
    rename_column :email_footers, :content, :html
    add_column :email_footers, :text, :text
    MovementLocale.all.each do |movement_locale|
      movement_locale.send(:ensure_email_footer_exists)
    end
  end
end
