class User < ActiveRecord::Base
end

class AddSourceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :source, :string
    User.update_all(:source => :movement)
  end
end
