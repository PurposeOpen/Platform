class ChangeJoinEmailBodyFromStringToText < ActiveRecord::Migration
  def up
    change_column :join_emails, :body, :text
  end

  def down
    change_column :join_emails, :body, :string
  end
end
