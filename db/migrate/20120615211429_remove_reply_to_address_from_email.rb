class RemoveReplyToAddressFromEmail < ActiveRecord::Migration
  def change
    remove_column :emails, :reply_to_address
  end
end
