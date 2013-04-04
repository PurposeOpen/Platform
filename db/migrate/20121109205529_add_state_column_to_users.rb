class AddStateColumnToUsers < ActiveRecord::Migration
  def change
  	# 'state' column was manually added to Production DB for performance reasons
    add_column :users, :state, :string, :limit => 64 unless User.column_names.include?('state')
  end
end
