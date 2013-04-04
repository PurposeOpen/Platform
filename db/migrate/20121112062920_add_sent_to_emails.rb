class AddSentToEmails < ActiveRecord::Migration
  def up
    add_column :emails, :sent, :boolean
    puts "Updating Emails#sent using push_sent_emails..."
    Push.pluck(:id).each do |push_id|
      activities_table = "push_#{push_id}"
      next unless table_exists? activities_table
      execute "UPDATE emails SET sent=1 where id in (SELECT DISTINCT email_id FROM #{activities_table})"
    end
    puts "Successfully updated!"
  end

  def down
    remove_column :emails, :sent
  end
end
