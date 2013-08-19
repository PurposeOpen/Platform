class AddPostcodeIndexToUsers < ActiveRecord::Migration
  def change
    add_index 'users', ['postcode']
  end
end
