class MergeFromNameAndFromAddress < ActiveRecord::Migration
  def change
    change_table :emails do |t|
      t.column :from, :string
      t.remove :from_name, :from_address
    end
  end
end