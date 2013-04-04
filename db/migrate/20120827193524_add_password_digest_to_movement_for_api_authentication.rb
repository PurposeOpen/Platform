class AddPasswordDigestToMovementForApiAuthentication < ActiveRecord::Migration
  def up
    add_column :movements, :password_digest, :string

    # This will assign default passwords; production passwords will be reset manually to random strings.
    Movement.all.each &:save!
  end

  def down
    remove_column :movements, :password_digest
  end
end
